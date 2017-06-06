Add/Remove Location&Device (powerzone) from Workspace Container for RES ONE Workspace
Version 1.0.0 - 6 june 2017
By Patrick Kaak (p.kaak@res.com)


This buildingblocks shows how you can add or remove a 'Device & Location' (PowerZone) to or from a Workspace Contianer.
It edits the exported configuration (buildingblock) of a Workspace and imports the edit again.
When the buildingblock has no powerzones after editing it will be disabled when imported.
When the buildingblock has a powerzone but was disabled before editing, it will be enabled when imported.


Requirements:
- Powershell 3.0 on the machine that runs the scripts
- RES ONE Workspace service account with enough rights to edit Workspace Containers and Powerzones (Locations & Devices)


Runbooks:
- Add/Remove Powerzone to Workspace Container

Modules:
- Export Buildingblock from ROW
- Import Buildingblock from ROW
- Add/Remove powerzone from workspace container
- Fix missing <workspaces> tag

Global Variables:
- ROA ServiceAccount for ROW console


Modules
1. Export Buildingblock from ROW
This modules exports a buildingblock based on objectguid. It uses the commandline from the RES ONE Workspace Console to export to an xml file. This modules needs the following module parameters to work:
- XML file: full path for the file to export. For example c:\temp\workspace1.xml
- ObjectGUID: GUID of the object to export including the {brackets}. When you need the objectguid of a Workspace Container, please export it one time manual and look in the xml for the <guid>-tag (please make sure you get it from withing the workspace-tag and not from a zone)
The module uses the Global Variable the run the command as another user

2. Import Buildingblock from ROW
This modules exports a buildingblock based on objectguid. It uses the commandline from the RES ONE Workspace Console to export to an xml file. This modules needs the following module parameters to work:
- XML file: full path for the file to import. For example c:\temp\workspace1.xml
The module uses the Global Variable the run the command as another user

3. Add/Remove powerzone from workspace container
This module adds or removes a Location & Device (Powerzone) from a buildingblock of a Workspace Container. If after editing, the workspace ends with no location attached, it will disable the workspace in the xml. If the workspace was disabled but a location is added, the workspace will be enabled in the xml.
This modules needs the following module parameters to work:
- XML file: full path for the file to export. For example c:\temp\workspace1.xml
- AddRemove: Please select to add or remove a powerzone
- PowerzoneGUID: GUID of the Location&Device (powerzone) to add/remove. Please use the guid in {brackets}.

The scripts cleans the buildingblock from all stuff that is not needed. It will remove any Powerlaunch entries (no idea why it is in there when you export by commandline) and it will also remove all powerzone-configurations, as we only need the guid of the powerzone.
For the rest we just use the powershell xpath functions to edit the buildingblock.

4. Fix missing <workspace> tag
In version v10.0.200 and older there is an error in the buildingblock that pwrtech.exe exports by commandline
This script fixes the missing <workspaces>-node by adding it to the xml file. This bug is fixed in ROW version 10.0.300. 



Runbooks:
1. Add/Remove Powerzone to Workspace Container
This runbook use all the above modules to add or remove a Location & Device (powerzone) to a Workspace Container.
The 'Fix missing workspace tag'-module is by default disabled. If you need this, you can enable it.
The runbook uses the following runbook parameters:
- AddRemove: Please select to add or remove a powerzone
- PowerzoneGUID: GUID of the Location&Device (powerzone) to add/remove. Please use the guid in {brackets}.
- ObjectGUID: GUID of the object to export including the {brackets}. When you need the objectguid of a Workspace Container, please export it one time manual and look in the xml for the <guid>-tag (please make sure you get it from withing the workspace-tag and not from a zone)
- TempEdit Location: Location where the buildingblock (xml) can be saved and edited
The runbook also uses a hidden parameter 'BuildingBlock Name' to create a filename with the GUID of the Workspace Container without the brackets. It also uses a hidden parameter 'XMLfile' that uses the templocation and filename for the buildingblock to full path for the buildingblock.
