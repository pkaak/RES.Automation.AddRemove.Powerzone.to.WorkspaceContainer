#based on ROW buildingblocks version 10.0.0.0

#set parameters
$buildingblocklocation = '$[XMLfile]'
$powerzoneguid = '$[PowerzoneGUID]'
$AddRemove = '$[AddRemove]'

#open buildingblock-xml
[xml]$ROWbuildingblock=get-content $buildingblocklocation

#set parent-node to the buildingblock-node within the xml
$parent_xpath = '/respowerfuse/buildingblock'
$nodes = $ROWbuildingblock.SelectNodes($parent_xpath)

#remove the stuff we do not need as we are just adding or removing existing powerzones
#remove Powerlaunch node
    $nodes | % {
        $child_node = $_.SelectSingleNode('powerlaunch')
        if ($child_node) {
            $_.RemoveChild($child_node) | Out-Null
            }
        }

#remove Powerzones node
    $nodes | % {
        $child_node = $_.SelectSingleNode('powerzones')
        if ($child_node) {
            $_.RemoveChild($child_node) | Out-Null
            }

        }

#add a new powerzone to the workspace container?
if ($AddRemove -match 'add') {
    #step 1: set parent to accesscontrol-node and add new access-node
    $parent_xpath = '/respowerfuse/buildingblock/workspaces/workspace/accesscontrol'
    $parent = $ROWbuildingblock.SelectNodes($parent_xpath)
    $access = $ROWbuildingblock.CreateElement('access')

    #step 2: create type-node in new access-node with 'powerzone' as textnode
    $type = $ROWbuildingblock.CreateElement('type')
    $typevalue = $ROWbuildingblock.CreateTextNode('powerzone')
    $type.AppendChild($typevalue) | Out-Null
    $access.appendchild($type) | Out-Null

    #step 3: create object-node in new access-node with the powerzoneguid as textnode
    $object = $ROWbuildingblock.CreateElement('object')
    $objectvalue = $ROWbuildingblock.CreateTextNode($powerzoneguid)
    $object.AppendChild($objectvalue) | Out-Null
    $access.appendchild($object) | Out-Null

    #step 4: append the new access-node to the accesscontrol-node
    $parent.appendchild($access) | Out-Null

    #check if the workspace container is enabled, if not, enable it
    if ($ROWbuildingblock.respowerfuse.buildingblock.workspaces.workspace.enabled -notmatch 'yes') {
        $ROWbuildingblock.respowerfuse.buildingblock.workspaces.workspace.enabled = 'yes'
    }

}

#remove powerzone from workspace container?
if ($AddRemove -match 'remove') {
    
    #search powerzoneguid in all the workspace container access nodes
    ForEach($access in $ROWbuildingblock.respowerfuse.buildingblock.workspaces.workspace.accesscontrol)
    {
        #select Node when right powerzoneguid is found
        $AccessObject = $access.SelectSingleNode("//object[.='$powerzoneguid']")
    
        if($AccessObject.'#text' -eq $powerzoneguid) {
            #remove the selected access-childnode from the accesscontrol
            #the objectnode has the accessnode as parent, which needs to be removed from his parent accesscontrol
            $AccessObject.ParentNode.ParentNode.RemoveChild($AccessObject.ParentNode)
            
        }
    }
    
    #check if there are any powerzones left, else disable the workspace container
    $CounterPowerzones=0
    
    #search for powerzones in the accesscontrol-node and count up when found
    for ($count=0; $count -lt $access.access.count; $count++) {
        if ($access.access[$count].type -match 'powerzone') {
            $CounterPowerzones++
        }
    }
    if ($CounterPowerzones -match 0) {
        $ROWbuildingblock.respowerfuse.buildingblock.workspaces.workspace.enabled = 'no'
    }
}

#and save everything back to disk
$ROWbuildingblock.Save($buildingblocklocation)
