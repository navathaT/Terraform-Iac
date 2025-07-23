pipeline {
  agent any

  environment {
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_TENANT_ID       = credentials('azure-tenant-id')

    // Backend and tfvars filenames based on the branch name
    TF_BACKEND_CONFIG   = "backend-${env.BRANCH_NAME}.tfbackend"
    TF_VAR_FILE         = "${env.BRANCH_NAME}.tfvars"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/navathaT/Terraform-Iac.git', branch: "${env.BRANCH_NAME}"
      }
    }

    stage('Terraform Init') {
      steps {
        sh "terraform init -backend-config=${TF_BACKEND_CONFIG}"
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
            sh "terraform plan -var-file=${TF_VAR_FILE} -out=tfplan-${env.BRANCH_NAME}"
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
        script {
          input message: "Approve deployment to ${env.BRANCH_NAME.toUpperCase()}?"
        }
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
