
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

    stage('Debug Workspace') {
      steps {
        sh 'pwd'
        sh 'ls -l'
      }
    }

    stage('Terraform Init') {
      steps {
        script {
          def envDir = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'dev') ? 'dev' : env.BRANCH_NAME
          dir(envDir) {
            def backendConfig = "backend-${envDir}.tfbackend"
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

          dir(envDir) {
            parallel(
              Validate: {
                sh "terraform validate -var-file=${envDir}.tfvars"
              },
              Plan: {
                sh "terraform plan -var-file=${envDir}.tfvars -out=tfplan-${envDir}"
              }
            )
          }
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
          dir(envDir) {
            sh "terraform apply -auto-approve tfplan-${envDir}"
          }
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
