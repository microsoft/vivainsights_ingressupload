using DescriptiveDataUploadApp;
using Microsoft.Identity.Client;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Cryptography.X509Certificates;

namespace HttpClientCallerApp
{
    public class Program
    {
        static HttpClient client = new HttpClient();
        private string appId = string.Empty;
        private string pathToZippedFile = string.Empty;
        private string tenantId = string.Empty;
        private string certName = string.Empty;
        private string scaleUnit = string.Empty;

        static void Main()
        {
            var program = new Program();
            program.TakeInputs();
        }

        public void TakeInputs()
        {
            var emptyInput = true;
            while (emptyInput)
            {
                Console.WriteLine("Please enter the following values. \nNote: no quotation marks required around the responses.\n\n");
                Console.WriteLine("AppId/Client ID:");
                appId = Console.ReadLine() ?? appId;

                Console.WriteLine("\nPlease enter the absolute path to the zipped file you wish to upload.\nFor example: C:\\\\Users\\\\JaneDoe\\\\OneDrive - Microsoft\\\\Desktop\\\\info.zip");
                pathToZippedFile = Console.ReadLine() ?? pathToZippedFile;

                Console.WriteLine("\nAzure Active Directory (AAD) Tenant ID:");
                tenantId = Console.ReadLine() ?? tenantId;

                Console.WriteLine("\nCertificate name for your registered application:");
                certName = Console.ReadLine() ?? certName;
                
                Console.WriteLine("\nScale unit of your tenant:");
                scaleUnit = Console.ReadLine() ?? scaleUnit;

                if (appId == string.Empty || pathToZippedFile == string.Empty || tenantId == string.Empty || certName == string.Empty || scaleUnit == string.Empty)
                {
                    Console.WriteLine("\nNone of the inputs can be empty strings or nulls. \nPlease go through the process again to upload your file.\n");
                    emptyInput = true;
                }
                else if (!IsGuid(appId) || !IsGuid(tenantId))
                {
                    Console.WriteLine("\nThe appId and/or the tenantId is not a valid Guid.\nPlease go through the process again to upload your file.\n");
                    emptyInput = true;
                }
                else
                {
                    emptyInput = false;
                }
            }
            new Program().RunAsync(appId, pathToZippedFile, tenantId, certName).GetAwaiter().GetResult();
        }

        private async Task RunAsync(string appId, string pathToZippedFile, string tenantId, string certName)
        {
            var appToken = await new Program().GetAppToken(tenantId, appId, certName);
            var bearerToken = string.Format("Bearer {0}", appToken);

            client.DefaultRequestHeaders.TryAddWithoutValidation("Authorization", bearerToken);
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));
            client.DefaultRequestHeaders.Add("x-nova-scaleunit", scaleUnit);
            
            var form = new MultipartFormDataContent();
            var byteArray = File.ReadAllBytes(pathToZippedFile);
            form.Add(new ByteArrayContent(byteArray, 0, byteArray.Length), "info", pathToZippedFile);
            var apiToAccess = string.Format(
                "{0}/{1}/ingress/connectors/HR/ingestions/fileIngestion",
                Constants.NovaPrdApi,
                tenantId);

            try
            {
                HttpResponseMessage message = await client.PostAsync(apiToAccess, form);

                if (message.StatusCode == HttpStatusCode.OK)
                {
                    string responseBody = await message.Content.ReadAsStringAsync();
                    Console.WriteLine($"\nRequest Status was success.\nIngestion is in progress. To check status, please visit the site.\n\nHere is the returned content:\n {responseBody})");
                }
                else
                {
                    Console.WriteLine($"\nRequest Status was not successful:\n {message.StatusCode}");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            Console.ReadLine();
        }

        private async Task<string> GetAppToken(string tenantId, string appId, string certName)
        {
            var authority = string.Format(
                "{0}/{1}",
                Constants.LoginBaseUrl,
                tenantId);

            var cert = FindCertificate(certName);
            var app = ConfidentialClientApplicationBuilder.Create(appId)
                         .WithCertificate(cert)
                         .WithAuthority(new Uri(authority))
                         .Build();

            string appToken = string.Empty;
            try
            {
                var authResult = await app.AcquireTokenForClient(
                    new[] { $"{Constants.NovaPrdUri}/.default" })
                    .WithSendX5C(true)
                    .ExecuteAsync()
                    .ConfigureAwait(false);

                appToken = authResult.AccessToken;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            return appToken;
        }

        private static X509Certificate2 FindCertificate(string certificateName)
        {
            using var localStore = new X509Store(StoreName.My, StoreLocation.LocalMachine);
            using var currentStore = new X509Store(StoreName.My, StoreLocation.CurrentUser);

            try
            {
                localStore.Open(OpenFlags.ReadOnly);
                var localCert = localStore.Certificates
                    .FirstOrDefault(c => c.SubjectName.Name == certificateName);

                currentStore.Open(OpenFlags.ReadOnly);
                var currentCert = currentStore.Certificates
                    .FirstOrDefault(c => c.SubjectName.Name == certificateName);

                if (localCert == null && currentCert == null)
                {
                    throw new InvalidOperationException($"\nFailed to load the certificate with find name {certificateName}");
                }

                return localCert != null ? localCert : currentCert;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"\nFailed to load the certificate with find name {certificateName}", ex);
            }
            finally
            {
                localStore.Close();
                currentStore.Close();
            }
        }

        private static bool IsGuid(string value)
        {
            Guid x;
            return Guid.TryParse(value, out x);
        }
    }
}
