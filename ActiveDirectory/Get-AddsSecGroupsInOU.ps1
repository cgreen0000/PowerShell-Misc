<#
.SYNOPSIS
This function will pull all of the group objects of the Security type from the specified OU.

.DESCRIPTION
This function will pull all of the group objects of the Security type from the specified OU.
Distinguished name of the organizational unit used 

.PARAMETER OU
This should be the distinguished name of the OU containing the security groups.

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-AddsSecGroupsInOU {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ValidateScript({ Get-ADOrganizationalUnit $_ })]
        [string]
        $OU
    )
    
    process {
        Get-ADGroup -SearchBase $OU -Filter {GroupCategory -eq 'Security'}
    }
}