cls
# Variables
$Script:Tenant_Id="d7a1777b-da56-4244-bbe3-12fd5e60cc5b"; # Id. de directorio (inquilino)
$Script:Client_Id="326df5b9-ac8c-4eb0-9c9d-1caed69cf0c7" # Id. de aplicación (cliente)
$Script:Client_Secret="aaB7Q~grTvxUH4H2xlYSAEMgCVaps5GZmOqh-" # Id. de secreto (valor)
# Función para generar el token para MS Graph
function fnGenerarTokenMSGraph() {
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
        return $null
    }
}
$MSGraphToken=fnGenerarTokenMSGraph