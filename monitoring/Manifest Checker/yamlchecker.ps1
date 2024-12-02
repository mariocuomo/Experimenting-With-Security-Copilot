param (
    [string]$script
)

# Function to read the YAML file
function Read-YamlFile {
    param (
        [string]$filePath
    )
    $yamlContent = Get-Content -Raw -Path $filePath
    $yamlObject = $yamlContent | ConvertFrom-Yaml
    return $yamlObject
}

# Function to check for warning keys
function Test-WarningKeys {
    param (
        [Array]$warningKeys,
        [Array]$keys
    )
    
    foreach ($key in $warningKeys) {
        if ($keys -notcontains $key) {
            Write-Host "[WARNING] The key '$key' is missing" -ForegroundColor blue 
        }
    }
}

# Function to check for error keys
function Test-ErrorKeys {
    param (
        [Array]$errorKeys,
        [Array]$keys
    )
    
    foreach ($key in $errorKeys) {
        if ($keys -notcontains $key) {
            Write-Host "[ERROR] The key '$key' is missing" -ForegroundColor Red
        }
    }
}

# Function to check for extra keys
function Test-ExtraKeys {
    param (
        [Array]$validKeys,
        [Array]$keys,
        [string]$where
    )
    
    foreach ($key in $keys) {
        if ($validKeys -notcontains $key) {
            Write-Host "[WARNING] Unnecessary key '$key' found in $where." -ForegroundColor blue 
        }
    }

}


# Function to validate SkillGroups
function Confirm-SkillGroups {
    param (
        [array]$skillgroups
    )
    $validSkillGroupsKeys = @("Format", "Skills", "Settings")
    $validSkillKeys = @("Name", "DisplayName", "Description", "ExamplePrompt", "Settings", "Inputs", "DescriptionForModel")
    $validInputKeys = @("Name", "Description", "Required", "DefaultValue")

    Write-Host "ANALYSING THE SkillGroups KEY ..."
    foreach ($skillgroup in $skillgroups) {
        $skillgroupCS = New-Object System.Collections.Hashtable([System.StringComparer]::Ordinal)
        foreach ($key in $skillgroup.Keys) {
            $skillgroupCS[$key] = $skillgroup[$key]
        }

        if ($skillgroupCS.Format -eq "API"){
            if (-not $skillgroupCS.Settings) {
                Write-Host  "[ERROR] The key 'Settings' is missing." -ForegroundColor red 
            }else{
                $validSettingsKeys = @("OpenApiSpecUrl", "EndpointUrl")
                
                Test-ExtraKeys -validKeys $validSettingsKeys -keys $skillgroupCS.Settings.Keys -where "Settings"
                if (-not $skillgroupCS.Settings.OpenApiSpecUrl) {
                    Write-Host  "[ERROR] The key 'OpenApiSpecUrl' is missing." -ForegroundColor red 
                }
                if (-not $skillgroupCS.Settings.EndpointUrl) {
                    Write-Host  "[WARNING] The key 'EndpointUrl' is missing." -ForegroundColor blue 
                }
            }
            return "API"
        }

        if ($skillgroupCS.Format -ne "KQL" -and $skillgroupCS.Format -ne "GPT" -and $skillgroupCS.Format -ne "LogicApp") {
            Write-Host "[ERROR] The key 'Format' is not a valid value (KQL, GPT, LogicApp)" -ForegroundColor red
            break
        }

        # Check for extra keys in SkillGroups
        Test-ExtraKeys -validKeys $validSkillGroupsKeys -keys $skillgroupCS.Keys -where "SkillGroups"
        if (-not $skillgroupCS.Format) {
            Write-Host "[ERROR] The key 'Format' is missing." -ForegroundColor red 
        }
         
        Write-Host ""

        $skillIndex = 0
        foreach ($skill in $skillgroupCS.Skills) {
            $skillIndex++
            Write-Host "ANALYSING SKILL NUMBER $skillIndex ..."
            Test-ExtraKeys -validKeys $validSkillKeys -keys $skill.Keys -where "Skill"

            $errorSkillsKeys = @("Name", "Description", "DisplayName")
            $warningSkillsKeys = @("ExamplePrompt", "DescriptionForModel")

            Test-ErrorKeys -errorKeys $errorSkillsKeys -keys $skill.Keys
            Test-WarningKeys -warningKeys $warningSkillsKeys -keys $skill.Keys

            if (-not $skill.Settings) {
                Write-Host  "[ERROR] The key 'Settings' is missing." -ForegroundColor red 
            } else {
                switch ($skillgroup.Format) {
                    "KQL" {
                        $validKQLSettingsKeys = @("Target", "Template", "TenantID", "SubscriptionID", "ResourceGroupName", "WorkspaceName", "Cluster", "Database")
                        Test-ExtraKeys -validKeys $validKQLSettingsKeys -keys $skill.Settings.Keys -where "KQL skill"
                        
                        $errorSettingsKeys = @("Target", "Template")
                        Test-ErrorKeys -errorKeys $errorSettingsKeys -keys $skill.Settings.Keys

                        if ($skill.Settings.Target -eq "Sentinel") {
                            $errorSentinelSettingsKeys = @("TenantID", "SubscriptionID", "ResourceGroupName", "WorkspaceName")
                            Test-ErrorKeys -errorKeys $errorSentinelSettingsKeys -keys $skill.Settings.Keys
                        } elseif ($skill.Settings.Target -eq "Kusto") {
                            $errorKustoSettingsKeys = @("TenantID", "Cluster", "Database")
                            Test-ErrorKeys -errorKeys $errorKustoSettingsKeys -keys $skill.Settings.Keys
                        }elseif ($skill.Settings.Target -ne "Defender") {
                            Write-Host "[ERROR] The key 'Target' is not a valid value (Sentinel, Kusto, Defender)" -ForegroundColor red
                        }
                        
                    }
                    "GPT" {
                        $validGPTSettingsKeys = @("ModelName", "Template")
                        Test-ExtraKeys -validKeys $validGPTSettingsKeys -keys $skill.Settings.Keys -where "GPT skill"
                        
                        $errorGPTSettingsKeys = @("ModelName", "Template")
                        Test-ErrorKeys -errorKeys $errorGPTSettingsKeys -keys $skill.Settings.Keys
                    }
                    "LogicApp" {
                        $validLogicAppSettingsKeys = @("SubscriptionId", "ResourceGroup", "WorkflowName", "TriggerName")
                        Test-ExtraKeys -validKeys $validLogicAppSettingsKeys -keys $skill.Settings.Keys -where "LogicApp skill"

                        $errorLogicAppSettingsKeys = @("SubscriptionId", "ResourceGroup", "WorkflowName", "TriggerName")
                        Test-ErrorKeys -errorKeys $errorLogicAppSettingsKeys -keys $skill.Settings.Keys
                    }
                }
            }

            $inputIndex = 0
            foreach ($input in $skill.Inputs) {
                $inputIndex++
                Write-Host "ANALYSING INPUT NUMBER $inputIndex ..."
                Test-ExtraKeys -validKeys $validInputKeys -keys $input.Keys -where "Input"
                $errorInputKeys = @("Name", "Description", "Required")
                $warningInputKeys = @("DefaultValue")
                
                Test-ErrorKeys -errorKeys $errorInputKeys -keys $input.Keys
                Test-WarningKeys -warningKeys $warningInputKeys -keys $input.Keys
            }
            Write-Host ""
        }
    }

    return ""
}

# Function to validate Descriptor
function Confirm-Descriptor {
    param (
        [hashtable]$descriptor,
        [string]$type
    )
    Write-Host "ANALYSING THE Descriptor KEY ..."

    $validDescriptorKeys = @("Name", "DisplayName", "Description", "DescriptionDisplay", "Category", "Prerequisites", "Icon", "SupportedAuthTypes", "Authorization")
    Test-ExtraKeys -validKeys $validDescriptorKeys -keys $descriptor.Keys -where "Descriptor"

    $errorDescriptorKeys = @("Name", "Description")
    Test-ErrorKeys -errorKeys $errorDescriptorKeys -keys $descriptor.Keys

    $warningDescriptorKeys = @("DescriptionDisplay", "Category", "Prerequisites", "Icon")
    Test-WarningKeys -warningKeys $warningDescriptorKeys -keys $descriptor.Keys

   
    if ($type -eq "API"){
        $warningAPIDescriptorKeys = @("SupportedAuthTypes", "Authorization")
        Test-WarningKeys -warningKeys $warningAPIDescriptorKeys -keys $descriptor.Keys

        Write-Host "ANALYSING THE SupportedAuthTypes METHODS ..."

        $supportedAuthType = @("AAD", "AADDelegated", "Basic", "ApiKey", "ServiceHttp", "OAuthClientCredentialsFlow","OAuthAuthorizationCodeFlow")
        foreach ($supportedAuthTypementioned in $descriptor.SupportedAuthTypes) {
            if ($supportedAuthType -notcontains $supportedAuthTypementioned) {
                    Write-Host "[ERROR] This authentication method '$supportedAuthTypementioned' is not supported" -ForegroundColor red 
            }
        }

        Write-Host "ANALYSING THE Authorization KEY ..."
        $Authorization = $descriptor.Authorization
        $AuthorizationType = $descriptor.Authorization.Type
        if (-not $AuthorizationType) {
            Write-Host "[WARNING] The key 'Type' is missing" -ForegroundColor blue
        }
        switch ($AuthorizationType) {
            "None" {

            }
            "ApiKey" {
                $requiredKeys = @("Key", "Location", "AuthScheme", "Type")
                Test-ExtraKeys -validKeys $requiredKeys -keys $Authorization.Keys -where "Authorization"

                $warningKeys = @("Key", "Location", "AuthScheme", "Type")
                Test-WarningKeys -warningKeys $warningKeys -keys $Authorization.Keys
            }
            "Basic" {
                $requiredKeys = @("Username", "Password", "Type")
                Test-ExtraKeys -validKeys $requiredKeys -keys $Authorization.Keys -where "Authorization"

                $warningKeys = @("Username", "Password", "Type")
                Test-WarningKeys -warningKeys $warningKeys -keys $Authorization.Keys
            }
            "AADDelegated" {
                $requiredKeys = @("EntraScopes", "Type")
                Test-ExtraKeys -validKeys $requiredKeys -keys $Authorization.Keys -where "Authorization"

                $warningKeys = @("EntraScopes", "Type")
                Test-WarningKeys -warningKeys $warningKeys -keys $Authorization.Keys
            }
            "OAuthAuthorizationCodeFlow" {
                $requiredKeys = @("AuthorizationEndpoint", "TokenEndpoint", "AuthorizationContentType", "ClientSecret", "ClientId", "Scopes", "Type")
                Test-ExtraKeys -validKeys $requiredKeys -keys $Authorization.Keys -where "Authorization"

                $warningKeys = @("AuthorizationEndpoint", "TokenEndpoint", "AuthorizationContentType", "ClientSecret", "ClientId", "Scopes", "Type")
                Test-WarningKeys -warningKeys $warningKeys -keys $Authorization.Keys
            }
            "OAuthClientCredentialsFlow" {
                $requiredKeys = @("TokenEndpoint", "AuthorizationContentType", "ClientSecret", "ClientId", "Scopes", "Type")
                Test-ExtraKeys -validKeys $requiredKeys -keys $Authorization.Keys -where "Authorization"

                $warningKeys = @("TokenEndpoint", "AuthorizationContentType", "ClientSecret", "ClientId", "Scopes", "Type")
                Test-WarningKeys -warningKeys $warningKeys -keys $Authorization.Keys
            }
            default {
                Write-Host "[ERROR] Unsupported AuthType: $AuthorizationType" -ForegroundColor Red
                return
            }
        }
    }
}


# Main function
function Main {
    param (
        [string]$yamlFilePath
    )
    try {
        $yamlObject = Read-YamlFile -filePath $yamlFilePath
        $type = Confirm-SkillGroups -skillgroups $yamlObject.SkillGroups
        Confirm-Descriptor -descriptor $yamlObject.Descriptor -type $type
    }
    catch {
        Write-Host "[FATAL] YAML FILE STRUCTURE IS INCORRECT - UNABLE TO PARSE AS YAML" -ForegroundColor DarkRed -BackgroundColor Gray
    }
    
}


# Run the main function with the path to the YAML file
Main -yamlFilePath $script
