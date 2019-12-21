pipeline {
 agent none

 stages
 {
  agent { label 'deploy' }
  stage('Checkout')
  {
   steps { 
    git branch: 'master', url: 'https://github.com/scmlearningcentre/seminar.git'
   }
  }

  stage('Build War')
  {
   agent { label 'deploy' }
   steps { 
    sh "mvn clean package"
   }
  }
 
  stage('Upload Artifactory') 
  {          
   agent { label 'deploy' }
   steps {          
    script { 
	    /* Define the Artifactory Server details */
        def server = Artifactory.server 'myartifactory'
        def uploadSpec = """{
            "files": [{
            "pattern": "target/samplewar.war", 
            "target": "demo"                   
            }]
        }"""
        
        /* Upload the war to  Artifactory repo */
        server.upload(uploadSpec)
    }
   }
  }

 stage('Build Image') 
  {
    agent { label 'deploy' }
    steps{
      script {
          docker.withRegistry( 'https://registry.hub.docker.com', 'dockerhub' ) {
             /* Build Docker Image locally */
             myImage = docker.build("adamtravis/testimg")

             /* Push the container to the Registry */
             myImage.push()
          }
      }
    }
  }

 stage('Run Sanity')
 {
  agent { label 'deploy' }
  steps {
    sh "./runsanity.sh testimg"
  }

 }
 
 stage('SonarQube Analysis') 
 {
    agent { label 'deploy' }
    steps{
     withSonarQubeEnv('mysonarqube') {
      sh 'mvn sonar:sonar'
     } 
    }
  }

 stage('Deployment K8S')
  {
    agent { label 'deploy' }
    steps {
      sh "kubectl get nodes"
    }
  }
    
 }
 post 
 {
  success {
    echo 'JENKINS PIPELINE SUCCESSFUL'
  }
  failure {
    mail body: 'Pipeline Details', subject: 'The Pipeline failed', to: 'scmlearningcentre@gmail.com'
  }
 }
}
