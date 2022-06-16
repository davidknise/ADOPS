Function New-AdoPullRequest
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,
        [String] $RepositoryId,

        [String] $Title,

        [String] $Description,

        [String] $SourceBranch,

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
        throw 'New-AdoPullRequest: RepositoryId is required.'
    }

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/pullrequests?'
    $uri += 'api-version=6.0'

    $body = @{ }
    $body.title = $Title

    if ($Description)
    {
        $body.description = $Description
    }

    $body.sourceRefName = "refs/heads/$SourceBranch"
    $body.targetRefName = "refs/heads/$TargetBranch"

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
        -Method 'POST' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
            repositoryId = $RepositoryId
        } `
        -BodyObject $body `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'New-AdoPullRequest'
)