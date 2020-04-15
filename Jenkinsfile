pipeline {
    agent any
    stages {
      stage("Deploying to EKS") {
        parallel {
          stage("Deploy via AWS CodeBuild") {
            steps {
              awsCodeBuild(
              projectName: "iiif-k8s-deployment",
              credentialsId: "services-team-jenkins-codebuild-trigger ",
              region: "us-east-1",
              credentialsType: "jenkins",
              sourceControlType: "project",
              sourceVersion: "IIIF-645",
              envVariables: "[ { K8S_DEPLOYMENT_APP, ${DEPLOYMENT_APP} }, { K8S_DEPLOYMENT_CONTAINER_IMAGE_TAG, ${CONTAINER_TAG} }, { K8S_NAMESPACE, ${NAMESPACE} } ]"
            )
            }
          }
        }
      }
    }
    post {
        // send build result notifications
        success {
            slackSend (
                channel: "avuong",
                color: "good",
                replyBroadcast: true,
                message: "Kubernetes deployment on ${NAMESPACE}: ${DEPLOYMENT_APP} with tag ${CONTAINER_TAG} - #${env.BUILD_NUMBER} ${currentBuild.currentResult} after ${currentBuild.durationString.replace(' and counting', '')} (<${env.RUN_DISPLAY_URL}|open>)",
                tokenCredentialId: "95231ecb-a041-445b-84c0-870db41e2ba8",
                teamDomain: "uclalibrary"
            )
        }
        failure {
            slackSend (
                channel: "avuong",
                color: "danger",
                replyBroadcast: true,
                message: "Kubernetes deployment on ${NAMESPACE}: ${DEPLOYMENT_APP} with tag ${CONTAINER_TAG} - #${env.BUILD_NUMBER} ${currentBuild.currentResult} after ${currentBuild.durationString.replace(' and counting', '')} (<${env.RUN_DISPLAY_URL}|open>)",
                tokenCredentialId: "95231ecb-a041-445b-84c0-870db41e2ba8",
                teamDomain: "uclalibrary"
            )
        }
    }
}
