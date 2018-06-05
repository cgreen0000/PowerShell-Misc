<#
.SYNOPSIS
This function is used to create device collections from security groups.

.DESCRIPTION
This function is used to create device collections from security groups. It will
name the collection based on the security group being targeted and then build a
query based on membership of that security group.

.PARAMETER GroupName
This is the name of the security group the collection will be built from. This 
parameter is required. It can take multiple group names at once.

.PARAMETER LimitingCollName
This is the name of the limiting collection. It will default to the built-in
All Desktop and Server Clients collection.

.PARAMETER RefreshType
This defines the refresh type for the collection. It must be either Manual, 
Periodic, ConstantUpdate, None, or Both.

.EXAMPLE
An example

.NOTES
General notes
#>
function New-SccmCollectionFromSecGroup {
    [CmdletBinding()]
    param (
        # Enter the name of the security group to target.
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateScript({ Get-ADGroup -Identity $_ })]
        [string[]]
        $GroupName,

        # Enter the name of the limiting collection.
        [Parameter(ValueFromPipeline)]
        [ValidateScript({ Get-CMDeviceCollection -Name $_ })]
        [string]
        $LimitingCollName = 'All Desktop and Server Clients',

        # Enter the refresh type for the collection.
        [Parameter(ValueFromPipeline)]
        [ValidateSet('Manual','Periodic','Continuous','None','Both')]
        [string]
        $RefreshType = 'Continuous'
    )
    
    begin {
        $DomainName = Get-ADDomain
    }
    
    process {
        $GroupName | ForEach-Object {
            try {
                $collectionExist = Get-CMDeviceCollection -Name $_
            }
            catch {
                $collectionExist = $false
            }
            
            if ($collectionExist) {
                Write-Host $_ 'already exists. Skipping collection creation.'
            } else {
                $QueryExp = 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,'`
                    + 'SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,'`
                    + 'SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client '`
                    + 'from SMS_R_System where SMS_R_System.SystemGroupName = '`
                    + '"{0}\\{1}"' -f $DomainName.NetBIOSName, $_

                try {
                    New-CMDeviceCollection -Name $_ `
                        -LimitingCollectionName $LimitingCollName `
                        -RefreshType $RefreshType | Out-Null
                    Write-Host 'New collection created for' $_ -ForegroundColor Green
                }
                catch {
                    Write-Host 'Could not create a collection for' $_ -ForegroundColor Red
                }

                try {
                    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $_ `
                        -RuleName $_ -QueryExpression $QueryExp | Out-Null
                    Write-Host 'New query created for' $_ -ForegroundColor Green
                }
                catch {
                    Write-Host 'Could not create a query for' $_ -ForegroundColor Red
                }
            }
        }
    }
    
    end {
    }
}