Function New-AdoPullRequestThread
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,
        [String] $RepositoryId,

        [String] $PullRequestId,

        [String] $Comment,

        [Object] $Author,

        [String] $FilePath,

        [Object] $LeftFileStart,

        [Object] $LeftFileEnd,

        [Object] $RightFileStart,

        [Object] $RightFileEnd,

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
        throw 'New-AdoPullRequestThread: RepositoryId is required.'
    }

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/pullrequests/{pullRequestId}/threads?'
    $uri += 'api-version=6.0'

    $body = @{ }
    $body.comments = @()
    $commentObject = @{
        content = $Comment
        threadContext = @{
            filePath = $FilePath
        }
    }

    if ($Author)
    {
        $commentObject.author = $Author
    }

    if ($LeftFileStart)
    {
        $commentObject.threadContext.leftFileStart = $LeftFileStart
    }

    if ($LeftFileEnd)
    {
        $commentObject.threadContext.leftFileEnd = $LeftFileEnd
    }

    if ($RightFileStart)
    {
        $commentObject.threadContext.RightFileStart = $RightFileStart
    }

    if ($RightFileEnd)
    {
        $commentObject.threadContext.RightFileEnd = $RightFileEnd
    }

    $body.comments += $commentObject

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'POST' `
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
    'New-AdoPullRequestThread'
)