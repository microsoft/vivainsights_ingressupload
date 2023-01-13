# Descriptive-Data-Uploading-App

Follow these steps to set up your console application:
1. Clone the app. Click on the green 'Clone' button on the top right. You can choose open with Visual Studio.
2. Create a new folder & select it for the clone to reside in, when Visual Studio prompts.
3. If Visual Studio was open, close it. Open/re-open Visual Studio as ***admin***.
4. On the right, click 'Open a local folder'. Choose the cloned folder.
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
4. Lastly, you will need to enter the Certificate Name that is configured in your registered application.
5. Temporarily, we will be requiring the scale unit to be entered but this will be discontinued shortly. For the purpose of this project, you may input ```novaprdwus2-02```. 
