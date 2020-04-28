# GossAudit

A minimal PowerShell module provided by Rackspace to audit Windows Server settings to ensure they are ready for enrollment automation.

**No changes / installations are performed as part of this script. It is read-only.**

During enrollment, monitoring and anti-virus agents will be deployed pointing to our infrastructure (if purchased)

## Prerequisites

- Windows Server 2008 R2 and above
- PowerShell 4 and above

## List of checks performed:

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

## Usage

Copy and paste the below into a PowerShell window to download, extract, and run the audit:

```PowerShell
if (-not (Test-Path C:\rs-pkgs\)) {New-Item -Type Directory C:\rs-pkgs\}
Invoke-WebRequest -Uri https://github.com/rackerlabs/GossAudit/archive/v1.0.0.0.zip -OutFile C:\rs-pkgs\GossAudit-1.0.0.0.zip
Expand-Archive -Path C:\rs-pkgs\GossAudit-1.0.0.0.zip -DestinationPath C:\rs-pkgs\GossAudit
Import-Module C:\rs-pkgs\GossAudit\GossAudit-1.0.0.0\GossAudit.psd1
Get-GossEnrollmentReadiness
```

**Manual steps:**

- Download `GossAudit.zip` from here: https://github.com/rackerlabs/GossAudit/archive/v1.0.0.0.zip
- Extract `GossAudit.zip` to a temporary location, for example `C:\rs-pkgs\GossAudit`
- Import the module using the `.psd1` file from the location the `.zip` has been extracted to:

```PowerShell
Import-Module C:\rs-pkgs\GossAudit\GossAudit.psd1
```

- Run the audit function

```PowerShell
Get-GossEnrollmentReadiness
```

## Recommendations

Output from the function will look similar to the following:

```PowerShell
C:\Windows\system32 PS>Get-GossEnrollmentReadiness
WARNING: User Account Control must be disabled prior to enrollment.
WARNING: An alternate AV product has been detected (Windows Defender Antivirus Service)
WARNING: This device is part of ad.contoso.com. Please remove prior to enrollment.
False
```

In this case, the device is not ready for enrollment, as `False` has been returned. Any warnings will need to be actioned.

When a device is ready for enrollment, the function will output `True`:

```PowerShell
C:\Windows\system32 PS>Get-GossEnrollmentReadiness
True
```

## Issues

If you have any technical issues with the module, you can create an issue using the below link:

https://github.com/rackerlabs/GossAudit/issues/new

Any other queries should be directed towards your Rackspace account team.
