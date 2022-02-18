cls
# Variables
$Script:Tenant_Id="d7a1777b-da56-4244-bbe3-12fd5e60cc5b"; # Id. de directorio (inquilino)
$Script:Client_Id="326df5b9-ac8c-4eb0-9c9d-1caed69cf0c7" # Id. de aplicación (cliente)
$Script:Client_Secret="aaB7Q~grTvxUH4H2xlYSAEMgCVaps5GZmOqh-" # Id. de secreto (valor)
$Script:MSGraphToken=$null
$Script:MSGraphTokenFecha=$null
# Función para generar el token para MS Graph
function fnGenerarTokenMSGraph(){
    try {
        $Cuerpo=@{
            Grant_Type="client_credentials"
            Scope="https://graph.microsoft.com/.default"
            client_Id=$Script:Client_Id
            Client_Secret=$Script:Client_Secret
        }
        $Conexion=Invoke-RestMethod -Uri "https://login.microsoftonline.com/$Script:Tenant_Id/oauth2/v2.0/token" -Method Post -Body $Cuerpo
        return $Conexion.access_token
    } catch {
        Write-Host "Error al obtener el token."
        #Write-Error $_.Exception.Message
        return $null
    }
}
# Obtener datos de una petición GET
function fnObtenerDatosMSGraph($MSGraph__Api) {
    try {
        $FechaHoraActual=(Get-Date).ToString("yyyyMMdd-HH")
        if($Script:MSGraphTokenFecha -ne $FechaHoraActual) {
            $Script:MSGraphTokenFecha=((Get-Date).ToString("yyyyMMdd-HH"))
            $Script:MSGraphToken=fnGenerarTokenMSGraph
        }
        if($Script:MSGraphToken) {
            return Invoke-RestMethod -Headers @{Authorization = "Bearer $($Script:MSGraphToken)"} -Uri $MSGraphApi -Method Get
        } else {
            return $null
        }
    } catch {
        Write-Host "Error al intentar conectarse a la api:" $MSGraphApi -ForegroundColor Red
        Write-Error $_.Exception.Message
        return $null
    }
}
# Función para obtener todos los datos de una api MS Graph
function fnObtenerTodosDatosMSGraph($MSGraphApi) {
    $DataAll = @()
    $Items__Initial=fnObtenerDatosMSGraph($MSGraphApi)
    foreach($Item in $Items__Initial.value) {
        $DataAll+=$Item
    }
    if($Items__Initial.'@odata.nextLink') {
        $Items__Next=fnObtenerTodosDatosMSGraph $Items__Initial.'@odata.nextLink'
        foreach($Item in $Items__Next){
            $DataAll+=$Item
        }
    }
    return $DataAll
}
# Obtener los datos de los usuarios
$MSGraphApi='https://graph.microsoft.com/v1.0/users?$top=9'
$UsersAll=fnObtenerTodosDatosMSGraph $MSGraphApi
$UsersAll | Export-Csv "D:\PowerShell\MS Graph\Export\Usuarios\Usuario_kaam1995.csv" -Encoding UTF8 -NoTypeInformation