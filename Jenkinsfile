node {
	stage('SCM Checkout') {
		git credentialsId: 'id1', url: 'https://github.com/narendar27/projCert'
	}
	stage('Mvn Package'){
	    sh 'mvn clean package'
	}
	stage('Buidl Docker Image'){
	    sh 'docker build -t naren27/php:2.0.0 .'
	}

}
