Function Get-AdoPullRequests
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $RepoName,
        [String] $RepositoryId,

        [String] $Status,

        [String] $TargetBranch,

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
        throw 'Get-AdoPullRequests: RepositoryId is required.'
    }

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repositoryId}/pullrequests?'

    if ($Status)
    {
        $uri += 'searchCriteria.status=active'
        $uri += '&'
    }

    if ($TargetBranch)
    {
        $uri += 'searchCriteria.targetRefName=refs/heads/{targetBranch}'
        $uri += '&'
    }
    $uri += 'api-version=6.0'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
            repositoryId = $RepositoryId
            targetBranch = $TargetBranch
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-AdoPullRequests'
)