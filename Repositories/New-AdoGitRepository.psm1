Function New-AdoGitRepository
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,

        [String] $OutFile
    )

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

Export-ModuleMember -Function @(
    'New-AdoGitRepository'
)