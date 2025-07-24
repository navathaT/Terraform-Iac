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

    stage('Terraform Init') {
      steps {
        script {
          if (fileExists("${TF_BACKEND_CONFIG}")) {
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
        script {
          if (fileExists("${TF_VAR_FILE}")) {
            echo "Using var-file for validate: ${TF_VAR_FILE}"
            sh "terraform validate -var-file=${TF_VAR_FILE}"
          } else {
            echo "Var-file ${TF_VAR_FILE} not found, running validate without var-file"
            sh "terraform validate"
          }
        }
      }
    }
    stage('Plan') {
      steps {
        script {
          if (fileExists("${TF_VAR_FILE}")) {
            echo "Using tfvars file: ${TF_VAR_FILE}"
            sh "terraform plan -var-file=${TF_VAR_FILE} -out=tfplan-${env.BRANCH_NAME}"
          } else {
            echo "tfvars file ${TF_VAR_FILE} not found. Running plan without tfvars."
            sh "terraform plan -out=tfplan-${env.BRANCH_NAME}"
          }
        }
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
