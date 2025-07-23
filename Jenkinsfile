pipeline {
  agent any

  environment {
    ARM_CLIENT_ID       = credentials('ARM_CLIENT_ID')
    ARM_CLIENT_SECRET   = credentials('ARM_CLIENT_SECRET')
    ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
    ARM_TENANT_ID       = credentials('ARM_TENANT_ID')
    TF_VAR_storage_key  = credentials('TF_STORAGE_KEY')
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
        sh 'terraform init -backend-config=${TF_BACKEND_CONFIG}'
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
            sh 'terraform plan -out=tfplan-${env.BRANCH_NAME}'
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
