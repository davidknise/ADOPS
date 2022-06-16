# Copyright (c) Microsoft Corporation. All rights reserved.

Function Invoke-AdoRestMethod
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Uri,

        [String] $BaseUri,

        [String] $ContentType = 'application/json',

        [Parameter(Mandatory=$true)]
        [String] $Method,

        [Object] $BodyObject,

        [String] $Body,

        [Hashtable] $ReplaceKeys,

        [Object] $Auth,

        [Object] $Headers = @{ },

        [String] $OutFile,

        [Switch] $Quiet
    )
    
    $restUri = $BaseUri + $Uri

    if ($ReplaceKeys)
    {
        foreach ($key in $ReplaceKeys.GetEnumerator())
        {
            $restUri = $restUri.Replace("{$($key.Name)}", $key.Value)
        }
    }

    if (-not $Auth)
    {
        $Auth = Get-AdoAuth

        if (-not $Auth)
        {
            throw 'Could not retrieve ADO authentication info.'
        }
    }

    if (-not $Auth.Headers)
    {
        $Auth.Headers = Get-BasicAuthHttpHeaders -Auth $Auth
    }

    if ($BodyObject)
    {
        $Body = $BodyObject | ConvertTo-Json -Depth 10
    }

    if ($Quiet.IsPresent)
    {
        Write-Verbose "Calling: $($Method.ToUpper()) $($restUri)"
    }
    else
    {
        Write-Host "Calling: $($Method.ToUpper()) $($restUri)"
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

Export-ModuleMember -Function @(
    'Invoke-AdoRestMethod'
)