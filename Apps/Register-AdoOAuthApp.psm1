<#
.SYNOPSIS
Registers a new Azure DevOps OAuth application.

.LINK
UI to register an OAuth application:
https://app.vsaex.visualstudio.com/app/register

.LINK
Authorization scopes:
https://go.microsoft.com/fwlink/?LinkID=513339
#>
Function Register-AdoOAuthApp
{
    Param
    (
        [String] $CompanyName,

        [String] $CompanyWebsite,

        [String] $TermsOfServiceUrl,
        [String] $PrivacyStatementUrl,

        [String] $ApplicationName,

        [String] $Description,

        [String] $LogoUrl,

        [String] $ApplicationWebsite,

        [Object] $AuthorizationCallbackUrl,

        [Array] $AuthorizedScopes
    )

    $uri = 'https://app.vsaex.visualstudio.com'

    $body = @{
        clientId = "00000000-0000-0000-0000-000000000000"
        providerName = $CompanyName
        providerUrl = $CompanyWebsite
        tosUrl = $TermsOfServiceUrl
        privacyUrl = $PrivacyStatementUrl
        appName = $ApplicationName
        appUrl = $ApplicationWebsite
        description = $Description
        appLogoUrl = $LogoUrl
        redirectUrl = $AuthorizationCallbackUrl
        scopes = $($AuthorizedScopes -join '+')
    }

    $body.completionOptions = $CompletionOptions

    $response = Invoke-AdoRestMethod `
        -Uri $uri `
        -Method 'POST' `
        -ContentType 'application/x-www-form-urlencoded; charset=UTF-8'
        -BodyObject $body `
        -OutFile $OutFile

    Write-Output $response
}

Export-ModuleMember -Function @(
    'Register-AdoOAuthApp'
)