Function Get-AdoPullRequestWorkItems
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepositoryId,

        [String] $PullRequestId,

        [String] $OutFile
    )

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/pullrequests/{pullRequestId}/workitems?'
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
    'Get-AdoPullRequestWorkItems'
)