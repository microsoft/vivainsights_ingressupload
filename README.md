# Descriptive-Data-Uploading-App

## Set up the application

1.	Clone the app. Open a command prompt and enter the following command: `git clone https://github.com/microsoft/vivainsights_ingressupload.git`.
2.	If Visual Studio was open, close it. Open or re-open Visual Studio as an administrator.
3.	On the right, select Open a local folder. Choose the cloned folder (vivainsights_ingressupload). 
   
    **Note:** The cloned folder will live in whichever directory you ran the git clone command from.
   
4.	On the right, in the **Solution Explorer** tab, double-click **DescriptiveDataUploadApp.sln**.

      <img width="350" alt="admin-upload-app-sln" src="https://user-images.githubusercontent.com/98846621/229250984-54df60e1-5249-4cd2-9f04-6272d63143a1.png">
      
5.	At the top of Visual Studio, you’ll need to select a start-up project. Select **DescriptiveDataUploadApp.csproj**.

6.	Select the play button to run the app or press Ctrl + F5 on your keyboard. 

      <img width="500" alt="admin-upload-app-play" src="https://user-images.githubusercontent.com/98846621/229251160-49ed137a-d3d2-4dc4-9035-d8679fe0e06b.png">

## Enter values in the console

**Note**: None of the values require quotation marks ("") around them.

After you set up the app, a console pops up asking you for the following inputs: 
1.	App (client) ID. Find this ID in the registered app information on the Azure portal under **Application (client) ID**. If you haven’t created and registered your app yet, follow the instructions in our main data import documentation, under Register a new app in Azure.

2.	Path to the zip folder. Format the path like this: `C:\\Users\\JaneDoe\\OneDrive - Microsoft\\Desktop\\info.zip`.

      **Note:** If you haven't downloaded the zip folder yet, find it [here](https://go.microsoft.com/fwlink/?linkid=2230444). Refer to our [main data-import documentation](https://learn.microsoft.com/viva/insights/advanced/admin/import-org-data-first#prepare-the-data-export) for more information about using the files in this folder.

3.	Azure Active Directory tenant ID. Also find this ID on the app's overview page under **Directory (tenant) ID**.

4.	Certificate name. This name is configured in your registered application. If you haven’t created a certificate yet, refer to [How to create a self-signed certificate](https://learn.microsoft.com/azure/active-directory/develop/howto-create-self-signed-certificate). After you upload the certificate, the certificate name shows up under **Description** in the Azure Portal. 
