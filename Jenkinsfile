pipeline {
  agent any

  environment {
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_TENANT_ID       = credentials('azure-tenant-id')

    TF_BACKEND_CONFIG   = "backend-${env.BRANCH_NAME}.tfbackend"
    TF_VAR_FILE         = "${env.BRANCH_NAME == 'main' ? 'dev.tfvars' : env.BRANCH_NAME + '.tfvars'}"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/navathaT/Terraform-Iac.git', branch: "${env.BRANCH_NAME}"
      }
    }

    stage('Debug') {
      steps {
        echo "Checking current directory and var file..."
        sh 'pwd'
        sh 'ls -l'
        script {
          if (fileExists(TF_VAR_FILE)) {
            echo "Found var file: ${TF_VAR_FILE}"
            sh "cat ${TF_VAR_FILE}"
          } else {
            error "Var file ${TF_VAR_FILE} does NOT exist!"
          }
        }
      }
    }

    stage('Terraform Init') {
      steps {
        script {
          if (fileExists(TF_BACKEND_CONFIG)) {
            echo "Using backend config: ${TF_BACKEND_CONFIG}"
            sh "terraform init -backend-config=${TF_BACKEND_CONFIG}"
          } else {
            echo "Backend config ${TF_BACKEND_CONFIG} not found. Running default terraform init"
            sh "terraform init"
          }
        }
      }
    }

    stage('Terraform Validate & Plan') {
      parallel {
        stage('Validate') {
          steps {
            sh "terraform validate -var-file=${TF_VAR_FILE}"
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
