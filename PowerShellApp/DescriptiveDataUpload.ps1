import-Module -Name MSAL.PS

$NovaPrdUri = "9d827643-d003-4cca-9dc8-71213a8f1644";
$NovaPpeUri = "01f9d889-ee31-41cb-85fa-3ad7e0981fa1";
$NovaPrdApi = "https://api.orginsights.viva.office.com/v1.0/scopes/";
$NovaPpeApi = "https://novappe.microsoft.com/v1.0/scopes/";
$loginURL = "https://login.microsoftonline.com"
$Scope = $NovaPpeUri + "/.default"
$Scopes = New-Object System.Collections.Generic.List[string]
$Scopes.Add($Scope)

function IsGuid {
        [OutputType([bool])]
        param
        (
                [Parameter(Mandatory = $true)]
                [string]$StringGuid
        )
 
        $ObjectGuid = [System.Guid]::empty
        return [System.Guid]::TryParse($StringGuid, [System.Management.Automation.PSReference]$ObjectGuid) # Returns True if successfully parsed
}

function ValidateString ([string] $inputString)
{
        if ([string]::IsNullOrWhitespace($inputString)) {
                Write-Host   "None of the inputs can be empty strings or nulls.`nPlease go through the process again to upload your file." -ForegroundColor Red
                exit 0
        }
}

function FindCertificate([string] $certificateName)
{
        try {
                $currentCertificate = Get-ChildItem Cert:\CurrentUser\My\ | Where-Object { $_.Subject -eq "$certificateName" }
                if ([string]::IsNullOrWhitespace($currentCertificate))
                {
                        $localCertificate =  Get-ChildItem Cert:\LocalMachine\My\ | Where-Object { $_.Subject -eq "$certificateName" }
                        if ([string]::IsNullOrWhitespace($localCertificate))
                        {
                                Write-Host   "Failed to load the certificate with find name "+$certificateName -ForegroundColor Red
                                exit 0
                        }
                        else 
                        {
                               
                                return $localCertificate
                        }
                }
                else 
                {
                        return $currentCertificate  
                }
        }
        catch {
                Write-Error $_
        }

}


function GetAppTokenFromClientSecret ( [string] $ClientId, [string]$ClientSecret, [string] $TenantId ) {

        $appToken = ""

        try {
                $app = [Microsoft.Identity.Client.ConfidentialClientApplicationBuilder]::Create($ClientId).WithClientSecret($ClientSecret).WithAuthority($("$loginURL/$TenantId")).Build()
                $TokenResult = $app.AcquireTokenForClient($Scopes).ExecuteAsync().Result;
                $appToken = $TokenResult.AccessToken
        }
        catch {
                Write-Error $_
        }
        
        return $appToken;
}

function GetAppTokenFromClientCertificate ( [string] $ClientId, [string]$certificateName, [string] $TenantId ) {

       
        $appToken = ""
        $certificate = FindCertificate $certificateName
        try {
               
                $app = [Microsoft.Identity.Client.ConfidentialClientApplicationBuilder]::Create($ClientId).WithCertificate($certificate).WithAuthority($("$loginURL/$TenantId")).Build()
                $TokenResult = $app.AcquireTokenForClient($Scopes).ExecuteAsync().Result;
                $appToken = $TokenResult.AccessToken
        }
        catch {
                Write-Error $_
        }
        
        return $appToken;
}



$ClientId = Read-Host -Prompt "AppId/Client ID"
ValidateString $ClientId
$pathToZippedFile = Read-Host -Prompt "Please enter the absolute path to the zipped file you wish to upload"
ValidateString $pathToZippedFile
$TenantId = Read-Host -Prompt "Azure Active Directory (AAD) Tenant ID"
ValidateString $TenantId
$novaScaleUnit = Read-Host -Prompt "Scale unit associated with the AAD Tenant ID"
ValidateString $novaScaleUnit

if (-NOT(IsGuid $ClientId) -or -NOT(IsGuid $TenantId)) {
        Write-Host   "The appId and/or the tenantId is not a valid Guid.`nPlease go through the process again to upload your file." -ForegroundColor Red
        exit 0
}       
$option = Read-Host -Prompt "Please type 1 if you wish to provide certificate name and type 2 if you wish to provide client secret"
$appToken
if($option.Equals("1"))
{
        $certificateName = Read-Host -Prompt "Certificate name for your registered application"
        ValidateString $certificateName
        $appToken = GetAppTokenFromClientCertificate $ClientId $certificateName $TenantId 
}
else 
{
        $ClientSecret = Read-Host -Prompt "Client secret for your registered application"
        ValidateString $ClientSecret
        $appToken = GetAppTokenFromClientSecret $ClientId $ClientSecret $TenantId 
}

$apiToAccess = $NovaPpeApi + $TenantId + "/ingress/connectors/HR/ingestions/fileIngestion"


try {
        $client = New-Object System.Net.Http.HttpClient
        $client.DefaultRequestHeaders.Add('x-nova-scaleunit', $novaScaleUnit);
        $client.DefaultRequestHeaders.Add("Authorization", "Bearer " + $appToken);
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $fileStream = [System.IO.File]::OpenRead($pathToZippedFile)
        $fileName = [System.IO.Path]::GetFileName($pathToZippedFile)
        $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
        $content.Add($fileContent, "info", $fileName)
        $result = $client.PostAsync($apiToAccess, $content).Result;
        $result.EnsureSuccessStatusCode()
        Write-Host "Request Status was success.`nIngestion is in progress. To check status, please visit the site.`n`nHere is the returned content:" -ForegroundColor Green
        $output = $result.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        Write-Host $output
}
catch {
        Write-Host "Request Status was not successful" -ForegroundColor Red
        Write-Error $_
}

