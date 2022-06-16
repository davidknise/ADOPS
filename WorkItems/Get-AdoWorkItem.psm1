Function Get-AdoWorkItem
{
    Param
    (
        [String] $Organization,

        [String] $Project,

        [String] $WorkItemId,

        [String] $OutFile
    )

    $uri = 'https://dev.azure.com/{organization}/{project}/_apis/wit/workitems/{id}?'
    $uri += 'api-version=6.0'

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'GET' `
        -ReplaceKeys @{
            organization = $Organization
            project = $Project
            id = $WorkItemId
        } `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Get-AdoWorkItem'
)