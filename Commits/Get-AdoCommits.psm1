Function Get-AdoCommits
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,
        [String] $RepositoryId,

        [Object] $SearchCriteria,

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

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/commits?'
    $uri += 'api-version=7.0'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
            repositoryId = $RepositoryId
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-AdoCommits'
)