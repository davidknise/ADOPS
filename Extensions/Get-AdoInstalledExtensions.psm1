Function Get-AdoInstalledExtensions
{
    Param
    (
        [String] $Organization,

        [String] $OutFile
    )
    
    if (-not $RepositoryId -and $RepoName)
    {
        $repo = Get-AdoRepository `
            -Organization $Organization `
            -Project $Project `
            -RepoName $RepoName

        $RepositoryId = $repo.Id
    }

    $uri = 'https://extmgmt.dev.azure.com/{organization}/_apis/extensionmanagement/installedextensions?'
    $uri += 'api-version=7.1-preview.1'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
            organization = $Organization
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-AdoInstalledExtensions'
)