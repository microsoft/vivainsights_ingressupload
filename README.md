# Descriptive-Data-Uploading-App

Follow these steps to set up your console application:
1. First, clone the app. To do this, open command prompt and enter: ```https://github.com/microsoft/vivainsights_ingressupload.git```.
2. If Visual Studio was open, close it. Open/re-open Visual Studio as ***admin***.
3. On the right, click 'Open a local folder'. Choose the cloned folder. Note that the cloned folder will reside in whichever directory you ran the ```git clone``` command from.
4. On the right, in the 'Solution Explorer' tab, double-click the .sln file. 

![image](https://user-images.githubusercontent.com/104855063/226287813-4df8c428-19bb-4f95-b116-e585db82a171.png)

5. At the top of Visual Studio, you will need to select a start up project. Select ```DescriptiveDataUploadApp.csproj```.
6. Click the play button to 'Run' the app. Or, press Ctrl + F5.
7. A console should pop up asking you for inputs.

# Values to enter in the console:

#### __Note__: None of the values require quotation marks ("") around them.

1. First, you will be asked for a client ID or app ID. This can be found in the registered app information on the Azure portal under ```Application (client) ID```.
   If you are yet to create and register an app, follow this:

    1. In the Azure portal, go to Azure Active Directory.
    2. In the side bar, click on 'App registrations'.
    3. Click on "+ New registration" on the top. Type in a name for the app and click 'Register'.
    4. You should be able to grab the client/app ID from the overview page.
2. Second, you will be expected to enter the path to the zipped file. The format of the path expected is:
 ```C:\\Users\\JaneDoe\\OneDrive - Microsoft\\Desktop\\info.zip```
3. Third, you will be expected to enter the Azure Active Directory tenant ID, which on app's overview page will appear as ```Directory (tenant) ID```.
4. Lastly, you will need to enter the Certificate Name that is configured in your registered application. Follow the steps in the "Create and export your public certificate" section here: ```https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-self-signed-certificate```.
Once certificate is uploaded, you can use the value under 'Description' in the Azure Portal as the value here:
![certExample](https://user-images.githubusercontent.com/104855063/227007691-2ec0bfa5-e0db-4802-aa64-1c6530556f34.png)
