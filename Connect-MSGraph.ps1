function Connect-MSGraph {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $true)]
        [Parameter(ParameterSetName = "Delegated", Mandatory = $true)]
        [string]
        $ClientId,
        # Parameter help description
        [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $true)]
        [string]
        $ClientSecret,
        # Parameter help description
        [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $true)]
        [Parameter(ParameterSetName = "Delegated", Mandatory = $false)]
        [string]
        $TenantID = "common",
        # Parameter help description
        [Parameter(ParameterSetName = "Delegated", Mandatory = $true)]
        [switch]
        $Delegated
    )

    begin {
        $resource = "https://graph.microsoft.com/"
        $servicePrincipalRequest = @{
            Uri         = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"
            Method      = 'POST'
            Body        = @{
                client_id     = $ClientId
                client_secret = $ClientSecret
                scope         = "https://graph.microsoft.com/.default"
                grant_type    = 'client_credentials'
            }
            ContentType = 'application/x-www-form-urlencoded'
        }
        $delegatedAccessRequest = @{
            Method = 'POST'
            Uri    = "https://login.microsoftonline.com/$TenantID/oauth2/devicecode"
            Body   = @{
                client_id = $ClientId
                resource  = $resource
            }
        }

        $verification = $Host.UI.PromptForChoice("Device Authentication", "Please verify that authentication with device code was sucessfull", @("&Yes", "&No"), 1)
        Write-Output $verification
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ServicePrincipal' {
                $accessToken = Invoke-RestMethod @servicePrincipalRequest
             }
            'Delegated' {
                $authenticationRequest = Invoke-RestMethod @delegatedAccessRequest
                Write-Host $authenticationRequest.message -ForegroundColor Yellow
                $regexExpression = 'code\s(\w*)\sto'
                $authenticationRequest.message -match $regexExpression | Out-Null
                Set-Clipboard -Value $Matches[1]
                Start-Process microsoft-edge:https://microsoft.com/devicelogin


                $verification = $Host.UI.PromptForChoice("Device Authentication", "Please verify that authentication with device code was sucessfull", @("&Yes", "&No"), 1)
                Write-Output $verification
                if ($verification -eq 0) {
                    $accessTokenRequestParameters = @{
                        Method = 'POST'
                        Uri    = "https://login.microsoftonline.com/$TenantId/oauth2/token"
                        Body   = @{
                            grant_type = "urn:ietf:params:oauth:grant-type:device_code"
                            code       = $authenticationRequest.device_code
                            client_id  = $ClientId
                        }
                    }
                    $accessToken = Invoke-RestMethod @accessTokenRequestParameters
                }else{
                    Write-Output "Authentication interrupted"
                }

            }
            Default {}
        }
    }

    end {
        Write-Output $accessToken
    }



}