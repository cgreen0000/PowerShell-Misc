<#
.SYNOPSIS
This function is used to query the collection membership for devices.

.DESCRIPTION
This function is used to query the collection membership for devices in Configuration
Manager. Multiple devices can be queried at once.

.PARAMETER Name
This designates the name of the device. It can accept multiple devices.

.PARAMETER format
This designates how the output should be formatted. It accepts console, json, or none.
The value is set to console. This will cause the function to write the output to the 
console by listing the device name and then each collection on a separate line. If the
data is needed for another function, override this behaviour by selecting json or none.
None will output the data as a PSObject.

.EXAMPLE
Get-SCCMCollectionMembership -Name Comp1,Comp2

Comp1 :
    -    Collection2
    -    All Systems
    -    All Desktop and Server Clients
Comp2 :
    -    TestCollection
    -    All Systems
    -    All Desktop and Server Clients

This will query the devices named Comp1 and Comp2 for collection memberships. The 
output will be formatted so that it can be viewed in the console.

.EXAMPLE
Get-SCCMCollectionMembership -Name Comp1,Comp2,Comp3,Comp4 -format None

Name         Collections
----         -----------
Comp1        {Collection2, All Systems, All Desktop and Server Clients}
Comp2        {TestCollection, All Systems, All Desktop and Server Clients}
Comp3        {All Systems, All Desktop and Server Clients}
Comp4        {Collection1, Collection2, All Systems, All Desktop and Server Clients...}

This will output an array of objects with the device names and collection membership. 
Collection data will be truncated if it goes over the FormatEnumerationLimit so this 
format is not the best for viewing the data.

.NOTES
This depends on the ConfigurationManager module. You should be connected to the site 
prior to using this function.

.LINK
Get-SccmSite
#>
function Get-SCCMCollectionMembership {
    [CmdletBinding(DefaultParameterSetName='Device')]
    param (
        # This specifies the devices or users to query.
        [Parameter(Mandatory, 
            ValueFromPipeline,
            Position=0)]
        [string[]]
        $Name,

        # This parameter indicates how to format the output.
        [Parameter(ValueFromPipeline,
            Position=1)]
        [ValidateSet('None','json','console')]
        [string]
        $format = 'console'
    )
    
    begin {
        $returnData = @()
        $Site = Get-SccmSite
        $SiteName = $Site.Name
        $SiteServer = $Site.Root
    }
    
    process {
        foreach ($targetName in $Name) {
            # targetObject and collectionArray will store the information collected.
            $targetObject = New-Object -TypeName psobject
            $collectionArray = @()

            $targetObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $targetName
            $targetResourceID = (Get-CMDevice -Name $targetName).ResourceID
            $targetCollIDs = (Get-WmiObject -ComputerName $SiteServer `
                -Class sms_fullcollectionmembership -Namespace root/sms/site_$SiteName `
                -Filter "ResourceID='$($targetResourceID)'").CollectionID

            foreach ($CollID in $targetCollIDs) {
                $Coll = Get-CMDeviceCollection -CollectionId $CollID
                $collectionArray += $Coll.Name
            }

            $targetObject | Add-Member -MemberType NoteProperty -Name 'Collections' -Value $collectionArray
            $returnData += $targetObject
        }
    }
    
    end {
        switch ($format) {
            console {
                # FormatEnumerationLimit is set at 4 by default. This loop prints the 
                # output in a way that it can all be read in the PowerShell console.
                for ($i = 0; $i -lt $returnData.Count; $i++) {
                    Write-Host $returnData[$i].Name ":"
                    for ($j = 0; $j -lt $returnData[$i].Collections.Count; $j++) {
                        Write-Host "    -   " $returnData[$i].Collections[$j]
                    }
                }
            }
            json { 
                # This probably isn't needed. Used it prior to console format.
                # Keeping it in case it is useful later.
                return $returnData | ConvertTo-Json
            }
            None { return $returnData }
            Default { 
                # The default value is console. This is just in case something goes wrong.
                return $returnData
            }
        }
    }
}
