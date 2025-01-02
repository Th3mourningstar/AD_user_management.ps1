# Import Active Directory module
Import-Module ActiveDirectory

# Define the log file path
$LogFilePath = "C:\Logs\AD_User_Management.log"

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $LogEntry = "$Timestamp [$LogLevel] $Message"
    Add-Content -Path $LogFilePath -Value $LogEntry
}

# Function to create a new user
function Create-ADUser {
    param (
        [string]$Username,
        [string]$FirstName,
        [string]$LastName,
        [string]$Password,
        [string]$OU
    )
    try {
        $FullName = "$FirstName $LastName"
        $SamAccountName = $Username

        Write-Log -Message "Attempting to create user: $Username in OU: $OU"

        New-ADUser -Name $FullName -GivenName $FirstName -Surname $LastName -SamAccountName $SamAccountName -UserPrincipalName "$Username@domain.com" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Path $OU -Enabled $true

        Write-Log -Message "User $Username successfully created."
    } catch {
        Write-Log -Message "Error creating user $Username: $_" -LogLevel "ERROR"
    }
}

# Function to modify an existing user
function Modify-ADUser {
    param (
        [string]$Username,
        [string]$PropertyName,
        [string]$PropertyValue
    )
    try {
        Write-Log -Message "Attempting to modify user: $Username - Setting $PropertyName to $PropertyValue"

        Set-ADUser -Identity $Username -Replace @{ $PropertyName = $PropertyValue }

        Write-Log -Message "User $Username successfully modified."
    } catch {
        Write-Log -Message "Error modifying user $Username: $_" -LogLevel "ERROR"
    }
}

# Function to delete a user
function Delete-ADUser {
    param (
        [string]$Username
    )
    try {
        Write-Log -Message "Attempting to delete user: $Username"

        Remove-ADUser -Identity $Username -Confirm:$false

        Write-Log -Message "User $Username successfully deleted."
    } catch {
        Write-Log -Message "Error deleting user $Username: $_" -LogLevel "ERROR"
    }
}

# Main Menu
function Show-Menu {
    Write-Host "Active Directory User Management" -ForegroundColor Green
    Write-Host "1. Create User"
    Write-Host "2. Modify User"
    Write-Host "3. Delete User"
    Write-Host "4. Exit"
}

# Main Loop
while ($true) {
    Show-Menu
    $Choice = Read-Host "Enter your choice"

    switch ($Choice) {
        "1" {
            $Username = Read-Host "Enter username"
            $FirstName = Read-Host "Enter first name"
            $LastName = Read-Host "Enter last name"
            $Password = Read-Host "Enter password" -AsSecureString
            $OU = Read-Host "Enter OU (e.g., OU=Users,DC=domain,DC=com)"

            Create-ADUser -Username $Username -FirstName $FirstName -LastName $LastName -Password (ConvertFrom-SecureString $Password -AsPlainText) -OU $OU
        }
        "2" {
            $Username = Read-Host "Enter username"
            $PropertyName = Read-Host "Enter property name to modify (e.g., Title, Department)"
            $PropertyValue = Read-Host "Enter new value for $PropertyName"

            Modify-ADUser -Username $Username -PropertyName $PropertyName -PropertyValue $PropertyValue
        }
        "3" {
            $Username = Read-Host "Enter username"

            Delete-ADUser -Username $Username
        }
        "4" {
            Write-Host "Exiting script. Goodbye!" -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
        }
    }
}
