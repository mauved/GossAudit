function Get-GossEnrollmentReadiness
{
    <#
        .SYNOPSIS
        Runs an audit against the current machine, and warns on any items that may affect the Rackspace GOSS enrollment.

        .DESCRIPTION
        Runs an audit against the current machine, and warns on any items that may affect the Rackspace GOSS enrollment.

        List of checks performed:

        - Operating System is eligible for Rackspace GOSS
        - User Account Control is disabled
        - The operating system is licensed
        - System Center Operations Manager (SCOM) is not installed
        - Sophos Anti-Virus is not installed
        - Ensures the below 3rd party Anti-Virus software is not installed
           - Avast!
           - BitDefender
           - ClamAV
           - ESET Smart Security
           - F-Protect
           - F-Secure
           - Kaspersky
           - Kaspersky Lab Antivirus
           - McAfee Security
           - Microsoft Security Essentials
           - Norton
           - Symantec Endpoint Protection
           - Windows Defender
           - Webroot Security
        - CrowdStrike is not installed
        - The device is not part of a domain

        If a check flags, we write to the warning stream with further information and recommendations to apply.

        .OUTPUTS
        [bool]

        .EXAMPLE
        Get-GossEnrollmentReadiness

        True

        Runs a check for GOSS enrollment readiness. There are no issues found, so True is returned.

        .EXAMPLE
        Get-GossEnrollmentReadiness

        WARNING: User Account Control must be disabled prior to enrollment.

        False

        Runs a check for GOSS enrollment readiness. Here it has flagged that UAC is enabled on the device, and returned False.

        .EXAMPLE
        Get-GossEnrollmentReadiness

        WARNING: Sophos services detected. Please remove prior to enrollment. (SAVAdminService, SAVService, Sophos Agent,
        Sophos AutoUpdate Service, Sophos Message Router, Sophos System Protection Service, Sophos Web Control Service,
        swi_filter, swi_service)
        WARNING: This device is part of lon.intensive.int. Please remove prior to enrollment.

        False

        Runs a check for GOSS enrollment readiness. Here it has flagged that Sophos is installed, and the device is part
        of the lon.intensive.int domain, and returned False.
    #>

    param ()
    begin
    {
        Write-Verbose "[$(Get-Date)] Begin :: $($MyInvocation.MyCommand)"
    }

    process
    {
        $User = [Security.Principal.WindowsIdentity]::GetCurrent();
        $IsAdmin = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole(
            [Security.Principal.WindowsBuiltinRole]::Administrator)

        if (-not $IsAdmin)
        {
            Write-Warning (
                "Please run this script under an account with administrator rights, " +
                "or run PowerShell as an administrator if you are already."
            )
            return $false # No need to run further checks
        }

        $OsInformation = Get-WmiObject Win32_OperatingSystem
        if ($OsInformation.Caption -notmatch "2008 R2|2012 R2|2016|2019")
        {
            Write-Warning "$($OsInformation.Caption) is not eligible for enrollment. Please contact your Account Team."
            return $false # No need to run further checks
        }

        if ($PSVersionTable.PSVersion.Major -lt 4)
        {
            Write-Warning -WarningVariable WarningPresent (
                "PowerShell must be at least version 4, currently running $($PSVersionTable.PSVersion.Major). " +
                "Please review and update as needed."
            )
            return $false # No need to run further checks
        }

        $Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        $UacStatus = (Get-ItemProperty $Path -ErrorAction SilentlyContinue).EnableLua
        if ($UacStatus -eq 1)
        {
            Write-Warning -WarningVariable WarningPresent "User Account Control must be disabled prior to enrollment."
        }

        $LicensingInfo = Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" |
            Where-Object {$_.PartialProductKey}
        if ($LicensingInfo.LicenseStatus -ne 1)
        {
            Write-Warning -WarningVariable WarningPresent "Windows is not activated."
        }

        $IsScomInstalled = Get-Service HealthService -ErrorAction SilentlyContinue
        if ($IsScomInstalled)
        {
            Write-Warning -WarningVariable WarningPresent "SCOM has been detected on this device. Please remove prior to enrollment."
        }

        $SophosServicesPresent = Get-Service $SOPHOS_SERVICES -ErrorAction SilentlyContinue
        if ($SophosServicesPresent)
        {
            $SophosServices = $SophosServicesPresent.Name -join ", "
            Write-Warning -WarningVariable WarningPresent "Sophos services detected. Please remove prior to enrollment. ($($SophosServices))"
        }

        $PossibleAntiVirusServices = Get-Service $AV_SERVICES -ErrorAction SilentlyContinue
        if ($PossibleAntiVirusServices)
        {
            $PossibleAntiVirusServices | ForEach-Object {
                Write-Warning -WarningVariable WarningPresent "An alternate AV product has been detected ($($_.DisplayName))"
            }
        }

        # This is a quick test to ensure drivers are present prior to confirming with WMI, as WMI is slow.
        $Path = "C:\Windows\System32\drivers\CrowdStrike"
        if (Test-Path $Path)
        {
            $CrowdstrikeProducts = Get-WmiObject -Class Win32_Product -Filter "Vendor LIKE '%CrowdStrike%'"
            if ($CrowdstrikeProducts)
            {
                $CrowdstrikeProductsString = $CrowdstrikeProducts.Name -join ", "
            }
            Write-Warning -WarningVariable WarningPresent "CrowdStrike products detected. Please remove prior to enrollment. ($($CrowdstrikeProductsString))"
        }

        $DomainInfo  = Get-WmiObject Win32_ComputerSystem
        if ($DomainInfo.PartOfDomain)
        {
            Write-Warning -WarningVariable WarningPresent "This device is part of $($DomainInfo.Domain). Please remove prior to enrollment."
        }

        if ($WarningPresent)
        {
            return $false
        }
        else
        {
            return $true
        }
    }

    end
    {
        Write-Verbose "[$(Get-Date)] End   :: $($MyInvocation.MyCommand)"
    }
}
