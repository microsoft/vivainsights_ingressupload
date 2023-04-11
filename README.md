# Descriptive-Data-Uploading-App

For each export, have your custom export app run this DescriptiveDataUploadApp.

In your custom app, include the following console values:

* AppID/ClientID. This ID is in the registered app information on the Azure portal under Application (client) ID.
* Absolute path to the zipped file. Format the path like this: C:\\Users\\JaneDoe\\OneDrive - Microsoft\\Desktop\\info.zip.
* Azure Active Directory tenant ID. This ID is also on the app's overview page under Directory (tenant) ID.
* Certificate name. This name is configured in your registered application. If you haven’t created a certificate yet, refer to [How to create a self-signed certificate](https://learn.microsoft.com/azure/active-directory/develop/howto-create-self-signed-certificate). After you upload the certificate, the certificate name shows up under Description in the Azure Portal.
