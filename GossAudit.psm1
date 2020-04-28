 # Copyright (c) 2019 Rackspace US, Inc.
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # [http://www.apache.org/licenses/LICENSE-2.0]
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.

# Load our functions
Get-ChildItem $PSScriptRoot\Public  -Filter '*.ps1' | Foreach-Object {. $_.FullName}

$VarParams = @{
    'Name'        = 'AV_SERVICES'
    'Description' = 'List of known 3rd party AV services that we check for.'
    'Scope'       = 'Script'
    'Force'       = $True
    'Option'      = 'readonly'
    'Value'       = @(
        'avast! antivirus',     # Avast!
        'aveservice',           # Avast!
        'AVP',                  # Kaspersky
        'bdss',                 # BitDefender
        'clamav',               # ClamAV
        'ekrn',                 # ESET Smart Security
        'fpavserver',           # F-Protect
        'fsma',                 # F-Secure
        'klblmain',             # Kaspersky Lab Antivirus
        'mcshield',             # McAfee Security
        'msmpeng',              # Microsoft Security Essentials
        'msmpsvc',              # Microsoft Security Essentials
        'navapsvc',             # Norton
        'symantec antivirus',   # Symantec Endpoint Protection
        'windefend',            # Windows Defender
        'WRSVC'                 # Webroot Security
    )
}
Set-Variable @VarParams

$VarParams = @{
    'Name'        = 'SOPHOS_SERVICES'
    'Description' = 'List of Sophos services.'
    'Scope'       = 'Script'
    'Force'       = $True
    'Option'      = 'readonly'
    'Value'       = @(
        "SAVService",
        "Sophos Agent",
        "Sophos AutoUpdate Service",
        "Sophos Message Router",
        "Sophos Web Control Service",
        "SAVAdminService",
        "swi_service",
        "swi_filter",
        "sophossps",
        "Sophos System Protection Service"
    )
}
Set-Variable @VarParams
