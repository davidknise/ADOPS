Function Get-AdoPullRequest
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,
        [String] $RepositoryId,

        [String] $PullRequestId,

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

    if ([String]::IsNullOrWhiteSpace($RepositoryId))
    {
        throw 'Get-AdoPullRequest: RepositoryId is required.'
    }

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/pullrequests/{pullRequestId}?'
    $uri += 'api-version=6.0'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
            repositoryId = $RepositoryId
            pullRequestId = $PullRequestId
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-AdoPullRequest'
)