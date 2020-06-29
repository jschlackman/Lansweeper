# Name: LansweeperADWriteback.ps1
# Author: James Schlackman
# Last Modified: Jun 29 2020
#
# Writes basic information gathered from Lansweeper scans back to the identified AD account associated with a workstation (not servers)
#
# Requirements:
#
# 1. A custom report must be created per the accompanying "Windows Active Directory Writeback.sql" file and a scheduled export defined
#    in Lansweeper settings with the "Directory" alert type. This should be run daily 5 minutes before the script is scheduled to run.
#
# 2. Must be run on a computer with the Active Directory module for Windows Powershell installed. By default it expects to be
#    run on the Lansweeper server that creates the export.
#
# 3. Must be run under a user account with write access to AD computer accounts (description, location, and serialNumber attributes).
#    Note: set AD permissions using ADSIEdit, as ADUC has a bug where the location attribute cannot be delegated for computer accounts.

Import-Module ActiveDirectory

# Get path to Lansweeper report export directory on this server.
$ExportPath = "$([IO.Path]::GetDirectoryName((Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\lansweeperservice).ImagePath.Replace('"','')))\export"
$ExportFile = "$ExportPath\Windows Active Directory Writeback.csv"

# Maximum allowed age of export file in hours (default is 24h assuming export is performed daily)
$MaxExportAge = 24

Write-Host ''

If (!(Test-Path -Path $ExportFile)) {
    Write-Host "Unable to locate export file " -ForegroundColor Red -NoNewline
    Write-Host $ExportFile
} Else {
    
    # Don't process if the export file age exceeds the defined maximum (avoid writing stale data to AD)
    If ((Get-ChildItem -Path $ExportPath).LastWriteTime -lt (Get-Date).AddHours(-$MaxExportAge)) {
    
        Write-Host "Export file is more than $($MaxExportAge)h old, skipping processing"
    
    } Else {

        # Read CSV file
        Write-Host "Reading export file $ExportFile..."

        # Lansweeper sometimes uses non-comma delimiters due to a bug. This checks the last character of the header row to determine the correct delimiter to use.
        $table = Import-Csv -Path $ExportFile -Delimiter (Get-Content -Path $ExportFile -First 1)[-1]


        If ($table.Count -eq 0) {
            Write-Host "No records found." -ForegroundColor Red
        } Else {
            Write-Host "Computer records loaded: $($table.Count)" -ForegroundColor Green
            Write-Host "Starting update..."

		    # Initialize progress counter
		    $progcount = 0
        }
	
        # Update AD accounts for each record in the table
        $table | ForEach-Object {

            [Int]$propc = ($progcount / $table.Count) * 100
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
}