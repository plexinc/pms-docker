pipeline{

	agent any

	environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub-cred-thomas')
	}

	stages {

		stage('Build') {

			steps {
				sh 'docker build -t dockerthomas/pms-container:latest .'
			}
		}

		stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

		stage('Push') {

			steps {
				sh 'docker push dockerthomas/pms-container:latest'
			}
		}
	}

	post {
		always {
			sh 'docker logout'
		}
	}

}
