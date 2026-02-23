<#
    .SYNOPSIS
    Writes basic information gathered from Lansweeper scans back to the identified AD account associated with a workstation (not servers)

    .DESCRIPTION

    Author: James Schlackman
    Last Modified: Dec 10, 2024

    Requirements:

    1. A custom report must be created per the accompanying "Windows Active Directory Writeback.sql" file and a scheduled export defined
       in Lansweeper settings with the "Directory" alert type. This should be run daily 5 minutes before the script is scheduled to run.

    2. Must be run on a computer with the Active Directory module for Windows Powershell installed. By default it expects to be
       run on the Lansweeper server that creates the export.

    3. Must be run under a user account with write access to AD computer accounts (description, location, and serialNumber attributes).
       Note: set AD permissions using ADSIEdit, as ADUC has a bug where the location attribute cannot be delegated for computer accounts.

    4. Default Windows scanning credential must be set in Lansweeper even if agentless scanning is not being used. AD computer objects will
       not be scanned at all if credentials with at least RO access to AD are not defined.

    .PARAMETER ReportFileName
    Specifies the CSV file from Lansweeper used for updating AD records. If relative, will check for the presence of the filename in the standard
    Lansweeper export path.

    .PARAMETER MaxExportAge
    Maximum allowed age of export file in hours (default is 24h assuming export is performed daily).
    
#>

#Requires -Modules ActiveDirectory

Param(
[Parameter()] [String]$ReportFileName = 'Windows Active Directory Writeback.csv',
[Parameter()] [Int]$MaxExportAge = 24
)

Import-Module ActiveDirectory

# Attempt to get path to Lansweeper report export directory on this server.
$lsServiceReg = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\lansweeperservice -ErrorAction SilentlyContinue
If ($lsServiceReg) {
    $reportPath = '{0}\export' -f (Get-Item ($lsServiceReg.ImagePath).Trim('"')).Directory.Fullname
} Else {$reportPath = '.'}

# Try to find report file based on passed parameter, checking the default report path if needed.
If (Test-Path $ReportFileName) {
    $reportFile = $ReportFileName
} ElseIf (Test-Path "$reportPath\$ReportFileName") {
    $reportFile = "$reportPath\$ReportFileName"
}

If (!(Test-Path -Path $reportFile)) {
    Write-Output ('Unable to locate export file {0}' -f $reportFile) -ForegroundColor Red -NoNewline
} Else {
    
    # Don't process if the export file age exceeds the defined maximum (avoid writing stale data to AD)
    If ((Get-Item -Path $reportFile).LastWriteTime -lt (Get-Date).AddHours(-$MaxExportAge)) {
    
        Write-Output ('Export file is more than {0}h old, skipping processing.' -f $MaxExportAge)
    
    } Else {

        # Read CSV file
        Write-Output ('Reading export file {0}...' -f $reportFile)

        # Lansweeper sometimes uses non-comma delimiters due to a bug. This checks the last character of the header row to determine the correct delimiter to use.
        $table = Import-Csv -Path $reportFile -Delimiter (Get-Content -Path $reportFile -First 1)[-1]


        If ($table.Count -eq 0) {
            Write-Output 'No records found.'
        } Else {
            Write-Output ('Computer records loaded: {0}' -f $table.Count)
            Write-Output 'Starting update...'
        }
	
        $proActivity = 'Updating AD computer objects'

        # Update AD accounts for each record in the table
        for ($index = 0; $index -lt $table.Count; $index++) {
        
            $record = $table[$index]
            
            # Attempt to locate the scanned AD object for this Lansweeper record
            $adObject = Get-ADComputer -Identity $record.ObjectGUID -Properties 'description'

            # If a matchign AD object was found
            If ($adObject) {

                Write-Progress -Activity $proActivity -Status $adObject.DistinguishedName -PercentComplete (($index / $table.Count) * 100)

                # Default description is the Model field, or SystemSKU if model is blank
                If ($record.Model.Trim()) {
                    $adObject.Description = $record.Model.Trim()
                } ElseIf ($record.SystemSKU.Trim()) {
                    $adObject.Description = $record.SystemSKU.Trim()
                }

                # Use SKU for Microsoft devices with bad Manufacturer info
                If (($record.SystemSKU.Trim()) -and ($record.Manufacturer -eq 'OEMC')) {
                    $adObject.Description = $record.SystemSKU.Trim() -replace '_',' '
                }

                If ($record.vmHost.Trim()) {
                    $adObject.Description += ' ({0})' -f $record.vmHost.Trim().ToUpper()
                }

                # Update AD account description with user display name if there is one
                If ($record.UserDisplayName.Trim()) {
                    $descSuffix = $record.UserDisplayName.Trim()
                }
                ElseIf ($record.Contact.Trim()) {
                    # Use the contact field if a matching user account could not be found
                    $descSuffix = $record.Contact.Trim()
                }
                Else {
                    # Use the state field as a last resort
                    $descSuffix = $record.State.Trim()
                }
                $adObject.Description += (' - {0}' -f $descSuffix)

                # Record a serial number if in Lansweeper, else clear attribute
                If ($record.SerialNumber.Trim()) {
                    $adObject.SerialNumber = $record.SerialNumber.Trim()
                } Else {
                    $adObject.SerialNumber = $null
                }

                # Record a Location if in Lansweeper, else clear attribute
                If ($record.Location.Trim()) {
                    $adObject.Location = $record.Location.Trim()
                } Else {
                    $adObject.Location = $null
                }
        
                # Commit changes
                Set-ADComputer -Instance $adObject
            }
        }

        Write-Progress -Activity $proActivity -Completed
        Write-Output 'Complete.'

    }
}
