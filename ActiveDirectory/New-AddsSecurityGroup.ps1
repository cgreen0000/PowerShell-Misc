<#
.SYNOPSIS
This function will validate and then create a new group in Active Directory.
This allows for more restrictive requirements than the New-ADGroup cmdlet
would so that you can create groups that conform to your preferred naming
convention.

.DESCRIPTION
Long description

.PARAMETER Name
This designates the name of the group to be created. It will define both the
userPrincipalName and the samAccountName. The samAccountName must
be unique within the domain and the userPrincipalName must be unique within 
the forest so the script will skip the creation of the group if it already
exists.

.PARAMETER Description
This designates the contents of the description field of the group. The 
maximum value for a description is 1024 characters.

.PARAMETER Note
This designates the contents of the note field of the group.

.PARAMETER OU
This designates the container object that the group will be placed in. This 
container must exist prior the group creation. This parameter will validate 
that the container object exists.

.PARAMETER Scope
This designates the scope of the group. This can be DomainLocal, Global, or 
Universal.

.PARAMETER Type
This designates the type of group to be created. The group be either Security
or Distribution.

.EXAMPLE
An example

.NOTES
General notes
#>
function New-AddsSecurityGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true)]
        [ValidateLength(1,50)]
        [ValidatePattern("[a-zA-Z0-9_]")]
        [string]$Name,

        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ValidateLength(1,1014)]
        [ValidatePattern("[a-zA-Z0-9 .]")]
        [string]
        $Description,

        [Parameter(ValueFromPipeline)]
        [ValidateLength(1,1014)]
        [ValidatePattern("[a-zA-Z0-9 .]")]
        [string]
        $Note,

        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ValidateScript({ Get-ADOrganizationalUnit $_ })]
        [string]
        $OU,

        [Parameter(ValueFromPipeline)]
        [ValidateSet('DomainLocal','Global','Universal')]
        [string]
        $Scope = 'DomainLocal',

        [Parameter(ValueFromPipeline)]
        [ValidateSet('Security','Distribution')]
        [string]
        $Type = 'Security'
    )
    
    begin {
    }
    
    process {
        
        try {
            $checkGroup = Get-ADGroup $Name -ErrorAction SilentlyContinue
        }
        catch {
            $checkGroup = $false
        }
        
        if ($checkGroup) {
            return "Security group $Name already exists! Skipping creation."
        } else {
            New-ADGroup -Name $Name -GroupScope $Scope `
                -Description $Description -GroupCategory $Type `
                -Path $OU -OtherAttributes @{'info'=$Note}
        }
    }
    
    end {
    }
}