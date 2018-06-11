<#
.SYNOPSIS
This function gets the current CMSite.

.DESCRIPTION
This function gets the current CMSite. Use the -connect parameter to switch 
to that location.

.PARAMETER connect
This will connect you to the site instead of returning site information.

.EXAMPLE
Get-SccmSite

Name      Used (GB)  Free (GB) Provider   Root      CurrentLocation
----      ---------  --------- --------   ----      ---------------
YourSite                                  CMSite    sccm.domain.local

This will get SCCM site information from PSDrive.

.Example
Get-SccmSite -connect

PS YourSite:\>

This will set the location to your SCCM site.

.NOTES
General notes
#>
function Get-SccmSite {
    [CmdletBinding()]
    param (
        [switch]$connect
    )
    
    begin {
        $SCCMSite = Get-PSDrive -PSProvider CMSite
        $SCCMSitePath = $SCCMSite.Name + ':'
    }
    
    process {
        if ($connect) {
            Set-Location $SCCMSitePath
        } else {
            return $SCCMSite
        }
    }
}
