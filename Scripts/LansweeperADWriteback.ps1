# Name: LansweeperADWriteback.ps1
# Author: James Schlackman
# Last Modified: Jun 26 2020
#
# Writes basic information gathered from Lansweeper scans back to the identified AD account associated with a workstation (not servers)
#
# Requirements:
#
# 1. Must be run under a user account that has AD-integrated read access to the Lansweeper SQL database (e.g. db_datareader permission)
# 2. Must be run on a computer with the Active Directory module for Windows Powershell installed.
# 3. Must have write access to AD computer accounts (description, location, and serialNumber attributes). Note: set AD permissions
#    using ADSIEdit, as ADUC has a bug where the location attribute cannot be delegated for computer accounts.

Import-Module ActiveDirectory

# Define connection to Lansweeper DB
$dataSource = "myserver"
$database = "lansweeperdb"

# Query all active scanned workstations from Lansweeper that have an AD account and an identified model
$query = @"
SELECT
    dbo.tblADObjects.sAMAccountName,
    dbo.tblADComputers.OU,
    dbo.tblAssetCustom.Manufacturer,
    dbo.tblAssetCustom.Model,
    dbo.tblAssetCustom.SystemSKU,
    dbo.tblAssetCustom.Contact,
    dbo.tblAssetCustom.Serialnumber,
    dbo.tblAssetCustom.Location
FROM
    dbo.tblComputersystem INNER JOIN
    dbo.tblADComputers ON dbo.tblComputersystem.AssetID = dbo.tblADComputers.AssetID INNER JOIN
    dbo.tblADObjects ON dbo.tblADComputers.ADObjectID = dbo.tblADObjects.ADObjectID INNER JOIN
    dbo.tblAssetCustom ON dbo.tblADComputers.AssetID = dbo.tblAssetCustom.AssetID
WHERE
    (NOT (dbo.tblAssetCustom.Model IS NULL)) AND
    (dbo.tblAssetCustom.State = 1) AND
    (dbo.tblComputersystem.Domainrole = 1)
ORDER BY
    dbo.tblADObjects.sAMAccountName
"@
 
# Setup SQL query
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = "Server=$dataSource;Database=$database;Integrated Security=True;"
$connection.Open()

Write-Host "Opening connection to '$database' on '$dataSource'..."

# If a database connection was opened successfully
If ($connection.State -eq "Open") {

    $command = $connection.CreateCommand()
    $command.CommandText  = $query

    Write-Host "Querying data..." 
    # Read SQL data
    $result = $command.ExecuteReader()

    # Load SQL into a table
    $table = New-Object System.Data.DataTable
    $table.Load($result)

    # Close SQL connection
    $connection.Close()

    If ($table.Rows.Count -eq 0) {
        Write-Host "No records found." -ForegroundColor Red
    } Else {
        Write-Host "Computer records loaded: $($table.Rows.Count)" -ForegroundColor Green
        Write-Host "Starting update..."
    }

    $progcount = 0
    #Write-Progress -Activity "Updating AD objects" -PercentComplete 0

    # Update AD accounts for each record in the table
    $table | ForEach-Object {

        [Int]$propc = ($progcount / $table.Rows.Count) * 100
        Write-Progress -Activity "Updating AD computer objects" -Status "$($_.sAMAccountName)".TrimEnd('$') -PercentComplete $propc

        $adobject = $null
        $useraccount = $null

        # Default description is the Model field
        [String]$desc = $_.Model

        # Use part of the SKU for Lenovo machines that have SKU data
        If (([String]$_.SystemSKU) -and ($_.Manufacturer -like "Lenovo*")) {
    
            $skuelements = ([String]$_.SystemSKU).Split("{_}")
            $desc = $skuelements[-1]
        }

        # Use SKU for Microsoft devices with bad Manufacturer info
        If (([String]$_.SystemSKU) -and ($_.Manufacturer -eq "OEMC")) {
    
            $desc = $_.SystemSKU -replace "_"," "
        }

        $sam = $_.sAMAccountName

        # Attempt to locate the scanned AD account for this Lansweeper record
        $adobject = Get-ADComputer -LDAPFilter "(sAMAccountName=$sam)" -Properties "managedBy" -SearchBase $_.OU

        # If the AD account was located, update AD object attributes    
        If ($adobject) {
        
            # Look up the user in the managedBy field if defined
            If ($adobject.ManagedBy) {
                $useraccount = $adobject.ManagedBy | Get-ADUser -Properties "displayName"
            }

            # Update AD account description with managedBy user display name if there is one
            If ($useraccount) {
                $desc += (" - $($useraccount.DisplayName)")
            }
            ElseIf ([String]$_.Contact) {
                # Use the contact field verbatim If a matching user account could not be found
                $desc += (" - $($_.Contact)")
            }

            # Set the finished description
            $adobject | Set-ADComputer -Description $desc
        

            # Record a serial number if in Lansweeper, else clear attribute
            If ([String]$_.SerialNumber) {
                $adobject | Set-ADComputer -Add @{serialNumber=$_.Serialnumber}
            } Else {
                $adobject | Set-ADComputer -Clear serialNumber
            }

            # Record a Location if in Lansweeper, else clear attribute
            If ([String]$_.Location) {
                $adobject | Set-ADComputer -Location $_.Location
            } Else {
                $adobject | Set-ADComputer -Clear location
            }
        }
        
        $progcount += 1

    }

    Write-Progress -Activity "Updating AD computer objects" -Completed
    Write-Output "Complete."

}