# Copyright (c) Microsoft Corporation. All rights reserved.

Function Get-BasicAuthHttpHeaders
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ParameterSetName = "Object")]
        [Object] $Auth,

        [Parameter(ParameterSetName = "Values")]
        [String] $Username,

        [Parameter(ParameterSetName = "Values")]
        [SecureString] $Password,

        [Parameter(ParameterSetName = "Object")]
        [Parameter(ParameterSetName = "Values")]
        [ValidateSet('Basic', 'PersonalAccessToken')]
        [String] $AuthType = 'PersonalAccessToken'
    )

    if ($PSCmdlet.ParameterSetName -ieq 'Object')
    {
        if ($Auth -eq $null)
        {
            throw 'Auth is required.'
        }

        $Username = $Auth.Username
        $Password = $Auth.Password
    }

    if (-not $Password)
    {
        throw 'Password is required.'
    }

    if (-not $Username)
    {
        # Always default to empty quotes
        $Username = '""'
    }

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $basicAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f $Username, [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr))))

    $headers = @{
        'Authorization' = "Basic $basicAuth"
        'X-TFS-FedAuthRedirect' = 'Suppress'
    }

    Write-Output $headers
}

# Copyright (c) Microsoft Corporation. All rights reserved.

Function Invoke-VstsRestMethod
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Uri,

        [String] $ContentType = 'application/json',

        [Parameter(Mandatory=$true)]
        [String] $Method,

        [String] $Body,

        [Hashtable] $ReplaceKeys,

        [Object] $Auth,

        [Object] $Headers = @{},

        [String] $OutFile,

        [Switch] $Quiet
    )

    $restUri = $Uri

    if ($ReplaceKeys)
    {
        foreach ($key in $ReplaceKeys.GetEnumerator())
        {
            $restUri = $restUri.Replace("{{$($key.Name)}}", $key.Value)
        }
    }

    if (-not $Auth)
    {
        $Auth = Get-VstsAuth

        if (-not $Auth)
        {
            throw 'Could not retrieve VSTS authentication info.'
        }
    }
    else
    {
        if (-not $Auth.Headers)
        {
            if ($Auth.Basic)
            {
                $Auth.Headers = Get-VstsAuthHttpHeaders `
                    -Username $Username `
                    -Password $Password
            }
            else
            {
                throw "Could not retreive VSTS authentication info.2"    
            }
        }
    }

    if ($Quiet.IsPresent)
    {
        Write-Verbose "Calling: $($restUri)"
    }
    else
    {
        Write-Host "Calling: $($restUri)"
    }

    $cleanHeaders = $Headers + $Auth.Headers

    if ([String]::IsNullOrWhiteSpace($Body))
    {
        $response = Invoke-RestMethod `
            -Uri $restUri `
            -ContentType $ContentType `
            -Method $Method `
            -Headers $cleanHeaders
    }
    else
    {
        $response = Invoke-RestMethod `
            -Uri $restUri `
            -ContentType $ContentType `
            -Method $Method `
            -Headers $cleanHeaders `
            -Body $Body
    }

    if ($OutFile)
    {
        Out-JsonFile -Object $response -FilePath $OutFile
    }

    Write-Output $response
}

Export-ModuleMember -Function @('Invoke-VstsRestMethod')

Export-ModuleMember -Function @(
    'Get-AdoAuthFromUser',
    'Get-BasicAuthHttpHeaders'
)