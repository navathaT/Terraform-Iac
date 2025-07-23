pipeline {
  agent any

  environment {
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    TF_VAR_storage_key  = credentials('45')
    TF_BACKEND_CONFIG   = "backend-${env.BRANCH_NAME}.tfbackend"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/navathaT/Terraform-Iac.git', branch: "${env.BRANCH_NAME}"
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init '
      }
    }

    stage('Terraform Validate & Plan') {
      parallel {
        stage('Validate') {
          steps {
            sh 'terraform validate'
          }
        }
        stage('Plan') {
          steps {
            sh "terraform plan -out=tfplan-${env.BRANCH_NAME}"
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
        input message: "Approve Deployment to ${env.BRANCH_NAME.toUpperCase()}?"
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve tfplan-${env.BRANCH_NAME}'
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
