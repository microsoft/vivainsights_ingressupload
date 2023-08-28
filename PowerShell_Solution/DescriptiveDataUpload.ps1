<#
 .Synopsis
    Runs the Data Descriptive upload api 
    
 .Description
    This script runs a POST request to https://api.orginsights.viva.office.com/v1.0/scopes/<tenantId>/ingress/connectors/HR/ingestions/fileIngestion

 .Parameter ClientID
   App (client) ID. Find this ID in the registered app information on the Azure portal under **Application (client) ID**. If you haven't created and registered your app yet, follow the instructions in our main data import documentation, under Register a new app in Azure.

 .Parameter pathToZippedFile
   Format the path like this: `C:\\Users\\JaneDoe\\OneDrive - Microsoft\\Desktop\\info.zip`.

 .Parameter TenantId
    Azure Active Directory tenant ID. Also find this ID on the app's overview page under **Directory (tenant) ID**.

 .Parameter certificateName 
   This certificate name is configured in your registered application. Either the certificateName or the ClientSecret parameter has to be provided 

 .Parameter ClientSecret 
    A secret string that the application uses to prove its identity when requesting a token. Either the certificateName or the ClientSecret parameter has to be provided 

 .Parameter ingressDataType 
    The ingressDataType can either be "HR" or "Survey"

 .Example
    .\DescriptiveDataUpload.ps1 -ClientId **** -pathToZippedFile  "C:\repos\temp\info.zip" -TenantId ***** -ingressDataType HR -ClientSecret **** 

 .Example
   .\DescriptiveDataUpload.ps1 -ClientId **** -pathToZippedFile  "C:\repos\temp\info.zip" -TenantId ***** -ingressDataType Survey -certificateName CN=ypochampally-certificate 

#>

param
(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "AppId/Client ID")]
        [string] $ClientId,
   
        [Parameter(Position = 1, Mandatory = $true,
                HelpMessage = "Absolute path to the zipped file you wish to upload")]
        [string] $pathToZippedFile,
   
        [Parameter(Position = 2, Mandatory = $true,
                HelpMessage = "Azure Active Directory (AAD) Tenant ID")]
        [string] $TenantId,

        [Parameter(Position = 3, Mandatory = $true,
                HelpMessage = "Ingress Data Type")]
        [string] $ingressDataType,

        [Parameter(Mandatory = $false,
                HelpMessage = "Certificate name for your registered application")]
        [string] $certificateName,

        [Parameter(Mandatory = $false,
                HelpMessage = "Client secret for your registered application")]
        [string] $ClientSecret 

);

import-Module -Name MSAL.PS
Add-Type -AssemblyName System.Net.Http

$NovaPrdUri = "9d827643-d003-4cca-9dc8-71213a8f1644";
$NovaPpeUri = "01f9d889-ee31-41cb-85fa-3ad7e0981fa1";
$NovaPrdApi = "https://api.orginsights.viva.office.com/v1.0/";
$NovaPpeApi = "https://novappe.microsoft.com/v1.0/";
$loginURL = "https://login.microsoftonline.com"
$Scope = $NovaPrdUri + "/.default"
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


function FindCertificate([string] $certificateName) {
        try {
                $currentCertificate = Get-ChildItem Cert:\CurrentUser\My\ | Where-Object { $_.Subject -eq "$certificateName" }
                if ([string]::IsNullOrWhitespace($currentCertificate)) {
                        $localCertificate = Get-ChildItem Cert:\LocalMachine\My\ | Where-Object { $_.Subject -eq "$certificateName" }
                        if ([string]::IsNullOrWhitespace($localCertificate)) {
                                Write-Host   "Failed to load the certificate with find name "+$certificateName -ForegroundColor Red
                                exit 0
                        }
                        else {
                               
                                return $localCertificate
                        }
                }
                else {
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

if (-NOT(IsGuid $ClientId) -or -NOT(IsGuid $TenantId)) {
        Write-Host   "The appId and/or the tenantId is not a valid Guid.`nPlease go through the process again to upload your file." -ForegroundColor Red
        exit 0
}   

#case insensitive match
if ($ingressDataType -eq "HR") {
        $ingressDataType = "HR"
}       
elseif ($ingressDataType -eq "Survey") {
        $ingressDataType = "Survey" 
}
else {
        Write-Host   'ingressDataType can either be "Survey" or "HR". `nPlease go through the process again to upload your file.' -ForegroundColor Red
        exit 0
}


$appToken = ""
if (-NOT([string]::IsNullOrWhitespace($certificateName))) {
        $appToken = GetAppTokenFromClientCertificate $ClientId $certificateName $TenantId 
}
elseif (-NOT([string]::IsNullOrWhitespace($ClientSecret))) {
        $appToken = GetAppTokenFromClientSecret $ClientId $ClientSecret $TenantId 
}
else { 
        Write-Host   "Either certificateName or ClientSecret has to be provided. `nPlease go through the process again to upload your file." -ForegroundColor Red
        exit 0
}

$DescriptiveDataUploadEndPoint = $NovaPrdApi + "scopes/" + $TenantId + "/ingress/connectors/" + $ingressDataType + "/ingestions/fileIngestion"


try {
        $client = New-Object System.Net.Http.HttpClient
        $client.DefaultRequestHeaders.Accept.Clear() 
        $mediaType = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue "application/json"
        $client.DefaultRequestHeaders.Accept.Add($mediaType);
        $client.DefaultRequestHeaders.Add("Authorization", "Bearer " + $appToken);
        
        $ScaleUnitEndPoint =  $NovaPrdApi + "tenants/" + $TenantId + "/scopes/" + $TenantId + "/scaleUnit"
        $scaleUnitResult = $client.GetAsync($ScaleUnitEndPoint).Result;
        $novaScaleUnit = $scaleUnitResult.Content.ReadAsStringAsync().GetAwaiter().GetResult().Replace("`"","")

       
        $client.DefaultRequestHeaders.Add('x-nova-scaleunit', $novaScaleUnit);
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $fileStream = [System.IO.File]::OpenRead($pathToZippedFile)
        $fileName = [System.IO.Path]::GetFileName($pathToZippedFile)
        $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
        $content.Add($fileContent, "info", $fileName)


        $result = $client.PostAsync($DescriptiveDataUploadEndPoint, $content).Result;
        $result.EnsureSuccessStatusCode()
        Write-Host "Request Status was success.`nIngestion is in progress. To check status, please visit the site.`n`nHere is the returned content:" -ForegroundColor Green
        $output = $result.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        Write-Host $output 

}
catch {
        Write-Host "Request Status was not successful" -ForegroundColor Red
        Write-Error $_
}

