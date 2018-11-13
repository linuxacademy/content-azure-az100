Configuration iis_dsc_file {
    
    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature IISManagementTools
        {
            Name = "Web-Mgmt-Tools"
            Ensure = "Present"
            IncludeAllSubFeature = $True
            LogPath = "C:\Scripts\IISMgmtToolsFeatures.txt"
 
        }
        
    }
}