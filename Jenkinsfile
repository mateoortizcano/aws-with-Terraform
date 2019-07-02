pipeline {
    agent {
        label 'Slave5'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '${BRANCH_NAME}']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    gitTool: 'Git_Centos',
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '###################',
                        url: '###################'
                    ]]
                ])
            }
        }
        stage('Install modules') {
            steps {
                sh '''
                cd #Ruta donde este el angular.json#################
                npm install
                '''
            }
        }
        stage('Unit tests') {
            steps {
                sh '''
                ng test --code-coverage
                '''
            }
        }
        stage('Sonar analysis') {
            steps {
                sh "${tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'}/bin/sonar-scanner -Dsonar.projectKey=co.com.ceiba.proteccion:perfilamiento.web.${BRANCH_NAME} -Dsonar.projectName=Proteccion-PerfilamientoWeb.${BRANCH_NAME} -Dproject.settings=./sonar-project.properties"
            }
        }
        stage('Deployment: Development') {
            when {
                branch 'develop'
            }
            steps {
                sh "ng build"
            }
            steps {
                withAwsCli(credentialsId: '###id development credentials###', defaultRegion: 'us-east-1']) {                    
                    sh '''
                    aws s3 cp #dist origin folder## s3://##bucket name## --recursive --acl public-read
                    '''                    
                }
                mail(subject: '[Protección-Perfilamiento en web] Nueva versión (Develop)',
                    body: 'Hay una nueva versión  en proceso de despliegue en ambiente Develop, en unos minutos podrá acceder a ella',
                    to: 'mateo.ortiz@ceiba.com.co jose.sanchez@ceiba.com.co johana.sepulveda@ceiba.com.co'
                )
            }
        }
        stage('End to end tests') {
            steps {
                sh '''
                ng e2e
                '''
            }
        }
        stage('Deployment: Production') {
            when {
                branch 'master'
            }
            steps {
                sh "ng build --prod"
            }
            steps {
                withAwsCli(credentialsId: '###id production credentials###', defaultRegion: 'us-east-1']) {                    
                    sh '''
                    aws s3 cp #dist origin folder## s3://##bucket name## --recursive --acl public-read
                    '''                    
                }
                mail(subject: '[Protección-Perfilamiento en web] Nueva versión (Producción)',
                    body: 'Hay una nueva versión  en proceso de despliegue en ambiente Producción, en unos minutos podrá acceder a ella',
                    to: 'mateo.ortiz@ceiba.com.co jose.sanchez@ceiba.com.co johana.sepulveda@ceiba.com.co'
                )
            }
        }
    }
    post {
        failure {
            mail(subject: "ERROR CI: Project name → ${env.JOB_NAME}",
                body: "Build failed in Jenkins: Project: ${env.JOB_NAME} Build \n Number: ${env.BUILD_NUMBER} \n Please go to ${env.BUILD_URL} and verify the build",
                to: 'jose.sanchez@ceiba.com.co mateo.ortiz@ceiba.com.co'
            )
        }
    }
}