Function Get-AdoRepositories
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $OutFile
    )

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories?'
    $uri += 'api-version=6.0'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-AdoRepositories'
)