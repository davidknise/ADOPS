# Copyright (c) Microsoft Corporation. All rights reserved.

if ((Get-Module 'PSAuth')) { Remove-Module 'PSAuth' }
Import-Module 'PSAuth'

Function Get-AdoAuth
{
    [CmdletBinding()]
    Param
    (
        [String] $FilePath,

        [ValidateSet('Basic', 'PAT')]
        [String] $AuthType,

        [Switch] $DoNotCache,

        [Switch] $Force
    )

    if (-not $FilePath)
    {
        $repoPath = Join-Path $PSScriptRoot '../'
        $repoPath = (Resolve-Path $repoPath).Path
        $FilePath = Join-Path $repoPath '.ado'
    }

    if (-not $AuthType)
    {
        $AuthType = 'PAT'
    }

    $auth = @{ }

    if (-not $Force.IsPresent -and (Test-Path -Path $FilePath -PathType 'Leaf'))
    {
        Write-Verbose "Reading cached auth: $FilePath"
        $Auth = Get-ProtectedData -Path $FilePath -Object
        $Auth = ConvertTo-Hashtable $Auth
        $Auth.Password = ConvertTo-SecureString -String $Auth.Password -AsPlainText -Force
    }
    else
    {
        switch ($AuthType)
        {
            'Basic'
            {
                $auth.Username = Read-Host -Prompt 'Username'
                $auth.Password = Read-Host -Prompt 'Password' -AsSecureString
                break
            }
            'PAT'
            {
                $auth.Password = Read-Host -Prompt 'Personal access token (PAT)' -AsSecureString
                break
            }
        }

        if (-not $DoNotCache.IsPresent)
        {
            Write-Host "Caching auth to: $FilePath"
            $rawBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($auth.Password)
            $authObj = @{
                Username = $auth.Username
                Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($rawBstr)
            }
            Set-ProtectedData -Path $FilePath -Object $authObj -Force
        }
    }

    if (-not $auth.Username)
    {
        # Always default to empty quotes
        $auth.Username = '""'
    }

    Write-Output $auth
}

Export-ModuleMember -Function @(
    'Get-AdoAuth'
)