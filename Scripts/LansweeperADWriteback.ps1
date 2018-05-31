# LansweeperADWriteback.ps1
# -------------------------
#
# Writes basic information gathered from Lansweeper scans back to the identified AD account associated with a computer
# Must be run under a user account that has write access to AD computer accounts, and AD-integrated read access to the Lansweeper SQL database
#
# Author: James Schlackman
#
# V1.0 - 2015-04-22 - First version
Import-Module ActiveDirectory

# Define connection to Lansweeper DB
$dataSource = "myserver"
$database = "lansweeperdb"

# Query all active scanned machines from Lansweeper that have an AD account and an identified model
$query = "SELECT dbo.tblADObjects.sAMAccountName, dbo.tblADComputers.OU, dbo.tblAssetCustom.Manufacturer, dbo.tblAssetCustom.Model, dbo.tblAssetCustom.SystemSKU, dbo.tblAssetCustom.Contact, dbo.tblAssetCustom.Serialnumber, dbo.tblAssetCustom.Location FROM dbo.tblADComputers INNER JOIN dbo.tblADObjects ON dbo.tblADComputers.ADObjectID = dbo.tblADObjects.ADObjectID INNER JOIN dbo.tblAssetCustom ON dbo.tblADComputers.AssetID = dbo.tblAssetCustom.AssetID WHERE (NOT (dbo.tblAssetCustom.Model IS NULL)) AND (dbo.tblAssetCustom.State = 1)"
 
# Setup SQL query
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.ConnectionString = "Server=$dataSource;Database=$database;Integrated Security=True;"
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText  = $query
 
# Read SQL data
$result = $command.ExecuteReader()

# Load SQL into a table
$table = new-object “System.Data.DataTable”
$table.Load($result)

# Update AD accounts for each record in the table
$table | ForEach-Object {

    $adobject = $null

    # Default description is the Model field
    [String]$desc = $_.Model

    # Use part of the SKU for Lenovo machines that have SKU data
    if (([String]$_.SystemSKU) -and ($_.Manufacturer -like "Lenovo*")) {
    
        $skuelements = ([String]$_.SystemSKU).Split("{_}")
        $desc = $skuelements[-1]
    }

    # Use SKU for Microsoft devices with bad Manufacturer info
    if (([String]$_.SystemSKU) -and ($_.Manufacturer -eq "OEMC")) {
    
        $desc = $_.SystemSKU -replace "_"," "
    }

    # Append the contact name if specified, or the location if specified
    if ([String]$_.Contact) {
        $desc += (" - " + $_.Contact)
    }
    elseif ([String]$_.Location) {
        $desc += (" - " + $_.Location)
    }


    $sam = $_.sAMAccountName

    # Attempt to locate the scanned AD account for this Lansweeper record
    $adobject = Get-ADComputer -LDAPFilter "(sAMAccountName=$sam)" -SearchBase $_.OU

    # If the AD account was located, update AD object attributes    
    if ($adobject) {
        
        # Update AD account description as per above
        $adobject | Set-ADComputer -Description $desc
        
        # Record a serial number if in Lansweeper, else clear attribute
        if ([String]$_.SerialNumber) {
            $adobject | Set-ADComputer -Add @{serialNumber=$_.Serialnumber}
        } else {
            $adobject | Set-ADComputer -Clear serialNumber
        }

        # Record a Location if in Lansweeper, else clear attribute
        if ([String]$_.Location) {
            $adobject | Set-ADComputer -Location $_.Location
        } else {
            $adobject | Set-ADComputer -Clear location
        }
    }

}

$connection.Close()