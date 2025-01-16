<#
    .SYNOPSIS
    Adds a database service dependency to the Lansweeper Server service.

    .DESCRIPTION
    Adds a service startup dependency to the Lansweeper Server service to ensure it
    does not start before the associated database service (either LocalDb or an SQL Server).

    Author: James Schlackman <james@schlackman.org>
    Last Modified: Jan 15, 2025

    .PARAMETER DependOnService
    Name of the service to depend on. Must exactly match either the internal name or display name.
    If not specified or not found, an attempt will be made to determine the correct service automatically.
#>

Param(
    [Parameter()] [string]$DependOnService = ''
)

$servicePath = 'HKLM:\SYSTEM\CurrentControlSet\Services'
$lsServiceName = 'lansweeperservice'
$lsDbServiceName = 'LansweeperLocalDbService'

# If a service was specified, try to match it to an existing service on this system.
If ($DependOnService -ne '') {

    $foundService = Get-Service $DependOnService -ErrorAction SilentlyContinue
    
    If ($foundService) {
        $DependOnService = $foundService.Name
    } Else {
        Write-Host ('No service matching "{0}" could be found on this system.' -f $DependOnService)
        $DependOnService = ''
    }
}

# Load any existing defined dependencies
$lsDependency = (Get-ItemProperty -Path "$servicePath\$lsServiceName" -Name 'DependOnService' -ErrorAction SilentlyContinue).DependOnService

# If dependent service was not specified, try to determine it automatically
If ($DependOnService -eq '') {

    Write-Host 'Attempting to determine service dependency automatically...'
    
	# If LocalDb is found, set that as the dependent service
	If (Get-Service -Name $lsDbServiceName -ErrorAction SilentlyContinue) {

		Write-Host 'Found Lansweeper LocalDB Service installed.'
		$DependOnService = $lsDbServiceName

	} Else {
		# Look for full SQL server installs
		$sqlServices = Get-Service | Where-Object {$_.Name -like 'MSSQL*'}

		Write-Host ('SQL instances found: {0}' -f @($sqlServices).Count)

		If (!$sqlServices) {

			# No SQL found, cannot set dependency
			Write-Host 'Lansweeper SQL service could not be determined.'

		} ElseIf (@($sqlServices).Count -eq 1) {

			# Only one SQL instance found
			$DependOnService = $sqlServices.Name

		} Else {

			# Multiple instances found, ask the user to select the correct instance
			$selectedSql = $sqlServices | Out-GridView -OutputMode Single -Title 'Select SQL instance that Lansweeper depends on'
			
			If ($selectedSql) {
				$DependOnService = $selectedSql.Name
			}
		}
	}
}

# If we determined a service dependency, try to set it
If ($DependOnService) {
    If ($lsDependency -contains $DependOnService) {
        Write-Host 'Dependency already defined.'
    } Else {
        Write-Host ('Setting dependency on service "{0}"' -f $DependOnService)
        $lsDependency += $DependOnService
        Set-ItemProperty -Path "$servicePath\$lsServiceName" -Name 'DependOnService' -Value $lsDependency
    }
}
