
 pipeline {
  agent any

  environment {
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/navathaT/Terraform-Iac.git', branch: "${env.BRANCH_NAME}"
      }
    }

    stage('Terraform Init') {
      steps {
        script {
          def envDir = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev') ? 'dev' : env.BRANCH_NAME
          def backendConfigFile = "${envDir}/backend-${envDir}.tfbackend"

          if (fileExists(backendConfigFile)) {
            echo "Using backend config: ${backendConfigFile}"
            sh "terraform init -backend-config=${backendConfigFile}"
          } else {
            echo "Backend config ${backendConfigFile} not found, running default terraform init"
            sh "terraform init"
          }
        }
      }
    }

    stage('Terraform Validate & Plan') {
      steps {
        script {
          def envDir = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev') ? 'dev' : env.BRANCH_NAME
          def varFile = "${envDir}/${envDir}.tfvars"

          if (!fileExists(varFile)) {
            error "Terraform var file '${varFile}' not found!"
          }
          echo "Using var file: ${varFile}"

          parallel(
            Validate: {
              sh "terraform validate -var-file=${varFile}"
            },
            Plan: {
              sh "terraform plan -var-file=${varFile} -out=tfplan-${envDir}"
            }
          )
        }
      }
    }

    stage('Approval for Staging/Prod') {
      when {
        anyOf {
          branch 'staging'
          branch 'prod'
        }
      }
      steps {
        input message: "Approve deployment to ${env.BRANCH_NAME.toUpperCase()}?"
      }
    }

    stage('Terraform Apply') {
      steps {
        script {
          def envDir = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev') ? 'dev' : env.BRANCH_NAME
          sh "terraform apply -auto-approve tfplan-${envDir}"
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
