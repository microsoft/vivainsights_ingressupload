# Descriptive-Data-Uploading-App

Whenever it exports the zip folder from your source system, have your custom export app automatically run the DescriptiveDataUploadApp. Clone the DescriptiveDataUploadApp to your machine by running the following command: `git clone https://github.com/microsoft/vivainsights_ingressupload.git`.


**Note:** If you haven't downloaded the zip folder for importing organizational data, you can download it [here](https://go.microsoft.com/fwlink/?linkid=2243005). Refer to our [main data-import documentation](https://learn.microsoft.com/viva/insights/advanced/admin/import-org-data-first#prepare-the-data-export) for more information about using the files in this folder. Or, for importing survey results, download [this zip folder](https://go.microsoft.com/fwlink/?linkid=2242706) and refer to our [documentation](https://learn.microsoft.com/viva/insights/advanced/admin/import-org-data-first).

After the custom export app runs the DescriptiveDataUploadApp, a console pops up asking you for the following inputs: 

1.	App (client) ID. Find this ID in the registered app information on the Azure portal under **Application (client) ID**. If you haven’t created and registered your app yet, follow the instructions in our main data import documentation, under Register a new app in Azure.

2.	Path to the zip folder. Format the path like this: `C:\\Users\\JaneDoe\\OneDrive - Microsoft\\Desktop\\info.zip`.

3.	Azure Active Directory tenant ID. Also find this ID on the app's overview page under **Directory (tenant) ID**.

4.	Certificate name. This name is configured in your registered application. If you haven’t created a certificate yet, refer to [How to create a self-signed certificate](https://learn.microsoft.com/azure/active-directory/develop/howto-create-self-signed-certificate). After you upload the certificate, the certificate name shows up under **Description** in the Azure Portal.
5. Ingress Data Type: `HR` or `Survey`
