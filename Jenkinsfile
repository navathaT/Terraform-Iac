trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  tfVersion: '1.6.0'
  azureServiceConnection: 'AzureServiceConnectionName'

stages:
- stage: ValidateAndPlan_Dev
  displayName: "Terraform Plan - Dev"
  jobs:
  - job: PlanDev
    steps:
    - task: TerraformInstaller@1
      inputs:
        terraformVersion: '$(tfVersion)'

    - task: AzureCLI@2
      inputs:
        azureSubscription: '$(azureServiceConnection)'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          cd environments/dev
          terraform init
          terraform validate
          terraform plan -var-file="dev.tfvars" -out=tfplan

- stage: Apply_Dev
  displayName: "Terraform Apply - Dev"
  dependsOn: ValidateAndPlan_Dev
  jobs:
  - deployment: ApplyDev
    environment: 'dev'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                cd environments/dev
                terraform init
                terraform apply -auto-approve tfplan

- stage: Apply_Staging
  displayName: "Terraform Apply - Staging"
  dependsOn: Apply_Dev
  jobs:
  - deployment: ApplyStaging
    environment: 'staging'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                cd environments/staging
                terraform init
                terraform plan -var-file="staging.tfvars" -out=tfplan
                terraform apply -auto-approve tfplan

- stage: Apply_Prod
  displayName: "Terraform Apply - Prod"
  dependsOn: Apply_Staging
  jobs:
  - deployment: ApplyProd
    environment: 'prod'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                cd environments/prod
                terraform init
                terraform plan -var-file="prod.tfvars" -out=tfplan
                terraform apply -auto-approve tfplan
