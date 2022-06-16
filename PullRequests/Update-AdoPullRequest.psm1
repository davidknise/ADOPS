Function Update-AdoPullRequest
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,
        [String] $RepositoryId,

        [Object] $PullRequest,
        [String] $PullRequestId,

        [String] $Status,

        [String] $Title,

        [String] $Description,

        [String] $TargetBranch,

        [Object] $CompletionOptions,

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
        throw 'Update-AdoPullRequest: RepositoryId is required.'
    }

    if ($PullRequest -and -not $PullRequestId)
    {
        $PullRequestId = $PullRequestId.pullRequestId
    }

    if ([String]::IsNullOrWhiteSpace($PullRequestId))
    {
        throw 'Update-AdoPullRequest: PullRequestId is required.'
    }

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/pullrequests/{pullRequestId}?'
    $uri += 'api-version=6.0'

    $body = @{ }

    if ($Status)
    {
        $body.status = $Status

        if ($Status -ieq 'completed')
        {
            if (-not $PullRequest -and $PullRequestId)
            {
                $PullRequest = Get-AdoPullRequest `
                    -Organization $Organization `
                    -Project $Project `
                    -RepositoryId $RepositoryId `
                    -PullRequestId $PullRequestId
            }

            $body.lastMergeSourceCommit = $PullRequest.lastMergeSourceCommit
        }
    }

    if ($Title)
    {
        $body.title = $Title
    }

    if ($Description)
    {
        $body.description = $Description
    }

    if ($TargetRefName)
    {
        $body.targetRefName = "refs/heads/$TargetBranch"
    }

    if (-not $CompletionOptions)
    {
        $CompletionOptions = @{ }
    }

    if ($CompletionOptions.deleteSourceBranch -eq $null)
    {
        $CompletionOptions.deleteSourceBranch = $true
    }

    if (-not $CompletionOptions.mergeStrategy)
    {
        $CompletionOptions.mergeStrategy = 'squash'
    }

    if ($CompletionOptions.transitionWorkItems -eq $null)
    {
        $CompletionOptions.transitionWorkItems = $true
    }

    $body.completionOptions = $CompletionOptions

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'PATCH' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
            repositoryId = $RepositoryId
            pullRequestId = $PullRequestId
        } `
        -BodyObject $body `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Update-AdoPullRequest'
)