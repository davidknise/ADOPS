Function Get-AdoRepository
{
    Param
    (
        [Parameter(ParameterSetName = 'RepoName')]
        [Parameter(ParameterSetName = 'RepoId')]
        [String] $Organization,

        [Parameter(ParameterSetName = 'RepoName')]
        [Parameter(ParameterSetName = 'RepoId')]
        [String] $Project,

        [Parameter(ParameterSetName = 'RepoName')]
        [String] $RepoName,

        [Parameter(ParameterSetName = 'RepoId')]
        [String] $RepositoryId,

        [Parameter(ParameterSetName = 'RepoName')]
        [Parameter(ParameterSetName = 'RepoId')]
        [String] $OutFile
    )

    if ($RepoName)
    {
        $repos = Get-AdoRepositories `
            -Organization $Organization `
            -Project $Project

        foreach ($repo in $repos.value)
        {
            if ($repo.name -ieq $RepoName)
            {
                Write-Output $repo
                break
            }
        }

        # Not Found
    }
    else
    {
        $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}?'
        $uri += 'api-version=6.0'

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
}

Export-ModuleMember -Function @(
    'Get-AdoRepository'
)