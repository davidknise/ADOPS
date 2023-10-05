Function New-AdoGitRepository
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,

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
        $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories'
        $uri += 'api-version=6.0'

        $response = Invoke-AdoRestMethod `
            -Uri $uri `
            -Method 'POST' `
            -ReplaceKeys @{
                organization = $Organization
                project = $Project
                repositoryId = $RepositoryId
            } `
            -BodyObject @{
                name = $RepoName
                project = @{
                    id = $ProjectId
                }
            } `
            -OutFile $OutFile

        Write-Output $response
    }
}

Export-ModuleMember -Function @(
    'New-AdoGitRepository'
)