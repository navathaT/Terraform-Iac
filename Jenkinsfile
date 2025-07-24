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

    stage('Debug') {
      steps {
        echo "Current directory and files:"
        sh 'pwd; ls -l'
      }
    }

    stage('Terraform Init') {
      steps {
        script {
          def backendConfig = "backend-${env.BRANCH_NAME}.tfbackend"
          if (fileExists(backendConfig)) {
            echo "Using backend config: ${backendConfig}"
            sh "terraform init -backend-config=${backendConfig}"
          } else {
            echo "Backend config ${backendConfig} not found, running default terraform init"
            sh "terraform init"
          }
        }
      }
    }

    stage('Terraform Validate & Plan') {
      steps {
        script {
          def varFile = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev') ? 'dev.tfvars' : "${env.BRANCH_NAME}.tfvars"
          if (!fileExists(varFile)) {
            error "Terraform var file '${varFile}' not found!"
          }
          echo "Using var file: ${varFile}"

          parallel(
            Validate: {
              sh "terraform validate -var-file=${varFile}"
            },
            Plan: {
              sh "terraform plan -var-file=${varFile} -out=tfplan-${env.BRANCH_NAME}"
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
        sh "terraform apply -auto-approve tfplan-${env.BRANCH_NAME}"
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
