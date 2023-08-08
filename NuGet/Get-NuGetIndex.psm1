Function Get-NuGetIndex
{
    Param
    (
        [String] $OutFile
    )

    $uri = 'https://pkgs.dev.azure.com/SecurityTools/_packaging/Guardian/nuget/v3/index.json'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-NuGetIndex'
)