function Import-AddsGroupsFromCsv {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path $_ })]
        $File
    )
    
    begin {
        $csvFile = Import-Csv -Path $File
    }
    
    process {
        $csvFile | ForEach-Object {
            New-AddsSecurityGroup -Name $_.Name -Description $_.Description `
                -Note $_.Note -OU $_.OU -Scope $_.Scope -Type $_.Type
        }
    }
    
    end {
    }
}