
function Get-prowlAntivirusProducts {
    [cmdletBinding()]
    param (
    
    )
    BEGIN
    {
        [Flags()] enum ProductState 
        {
            Off         = 0x0000
            On          = 0x1000
            Snoozed     = 0x2000
            Expired     = 0x3000
        }
        
        [Flags()] enum SignatureStatus
        {
            UpToDate     = 0x00
            OutOfDate    = 0x10
        }
        
        [Flags()] enum ProductOwner
        {
            NonMs        = 0x000
            Windows      = 0x100
        }
        
        # define bit masks
        
        [Flags()] enum ProductFlags
        {
            SignatureStatus = 0x00F0
            ProductOwner    = 0x0F00
            ProductState    = 0xF000
        }
    }
    PROCESS
    {
        $AntivirusProduct = Get-CimInstance -Namespace root/SecurityCenter2 -Classname AntiVirusProduct
        foreach($avProduct in $AntivirusProduct)
        {
            $exe = $avProduct.pathToSignedReportingExe | Split-Path -Leaf
            
            $cimFilter = "name='$exe'"
            $cimProc = get-cimINstance win32_process -filter $cimFilter

            [UInt32]$state = $avProduct.productState

            [PSCustomObject]@{
                ProductName = $avProduct.DisplayName
                ProductState = [ProductState]($state -band [ProductFlags]::ProductState)
                SignatureStatus = [SignatureStatus]($state -band [ProductFlags]::SignatureStatus)
                Owner = [ProductOwner]($state -band [ProductFlags]::ProductOwner)
                EXE = $exe
                ProcessIds = $cimProc.processId -join ','
            }
        }
    }
}


<#
$registeredAV = Get-AntivirusName


$cimFilter = "name='" + ($array -join "' or name='") +"'"
$cimProc = get-cimINstance win32_process -filter "Name "
#>