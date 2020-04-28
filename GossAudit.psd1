@{
    Description       = 'PowerShell module to audit readiness for GOSS enrollment.'
    ModuleToProcess   = 'GossAudit.psm1'
    ModuleVersion     = '1.0.0.0'
    GUID              = '4d1ac0f2-2260-4618-b173-f0064d30bd09'
    Author            = 'ryan0603'
    CompanyName       = 'Rackspace'
    Copyright         = '(c) 2020 Rackspace. All rights reserved.'
    PowerShellVersion = '4.0'
    RequiredModules   = @()
    FunctionsToExport = @(
        'Get-GossEnrollmentReadiness'
    )
    PrivateData       = @{
        PSData = @{
            Tags      = @(
                'GOSS',
                'RPC-V'
            )
            OSVersion = '6.1'
        }
    }
}
