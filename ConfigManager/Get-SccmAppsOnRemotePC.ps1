<#
    .SYNOPSIS
        Get-SccmAppsOnRemotePC retrieves a listing of installed software on a remote PC.
    .DESCRIPTION
        Get-SccmAppsOnRemotePC retrieves a listing of installed software on a remote PC. This is 
        based on the information contained in the CCM_MSIProduct class of the root\ccm\CIModels 
        namespace for WMI. This information only exists on devices with the CCM Client.
    .PARAMETER targetPC
        This specifies the remote device to be queried. It defaults to the local computer.
    .PARAMETER format
        This indicates if the output should be formatted. It defaults to true.
    .EXAMPLE
        Get-SccmAppsOnRemotePC -format
        
        ProductName                         ProductCode                            ProductVersion 
        -----------                         -----------                            --------------  
        Tools for .Net 3.5                  {1690CE56-2231-4E59-9006-A0876D949EA8} 3.11.50727     
        64 Bit HP CIO Components Installer  {13DA9C7C-EBFB-40D0-94A1-55B42883DF21} 21.2.1         
        7-Zip 18.01                         {23170F69-40C1-2701-1801-000001000000} 18.01.00.0     

        This command will create a formatted table of applications installed on the local computer.
    .EXAMPLE
        Get-SccmAppsOnRemotePC -targetPC Comp01 -format

        ProductName                         ProductCode                            ProductVersion 
        -----------                         -----------                            -------------- 
        64 Bit HP CIO Components Installer  {13DA9C7C-EBFB-40D0-94A1-55B42883DF21} 21.2.1         
        Adobe Acrobat Reader DC             {AC76BA86-7AD7-1033-7B44-AC0F074E4100} 18.011.20038   
        Adobe Refresh Manager               {AC76BA86-0804-1033-1959-001824214663} 1.8.0          

        This command creates a formatted table of applications installed on the remote computer
        named Comp01.
    .EXAMPLE
        Get-SccmAppsOnRemotePC -targetPC COMP01
        
        __GENUS          : 2
        __CLASS          : CCM_MSIProduct
        __SUPERCLASS     : 
        __DYNASTY        : CCM_MSIProduct
        __RELPATH        : CCM_MSIProduct.ProductCode="{9A25302D-30C0-39D9-BD6F-21E6EC160475}"
        __PROPERTY_COUNT : 5
        __DERIVATION     : {}
        __SERVER         : COMP01
        __NAMESPACE      : root\ccm\CIModels
        __PATH           : \\COMP01\root\ccm\CIModels:CCM_MSIProduct.ProductCode="{9A25302D-3...
        LocalPackage     : c:\windows\Installer\9cca5450.msi
        ProductCode      : {9A25302D-30C0-39D9-BD6F-21E6EC160475}
        ProductName      : Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.17
        ProductVersion   : 9.0.30729
        UpgradeCode      : 
        PSComputerName   : COMP01

        This command gets the installed applications on the remote computer named COMP01 but it
        does not apply any formatting to the data. This can be useful for retrieving some of the
        information that would otherwise be hidden when formatting is applied.
    .LINK
        Get-WmiObject
#>
function Get-SccmAppsOnRemotePC () {
    param ( 
    [Parameter(Mandatory=$false)]
    [string]$targetPC = $env:COMPUTERNAME,
    
    [Parameter(Mandatory=$false)]
    [switch]$format
    )
    
    if ($format) {
        Get-WmiObject -Namespace root\ccm\CIModels -Class CCM_MSIProduct -ComputerName $targetPC | 
            Sort-Object ProductName |
            Format-Table ProductName,ProductCode,ProductVersion -autosize
    }
    else {
        Get-WmiObject -Namespace root\ccm\CIModels -Class CCM_MSIProduct -ComputerName $targetPC
    }
}