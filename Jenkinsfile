pipeline {
    agent any 

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_USER = "vinaydocker542"
        GIT_CREDENTIALS_ID = "github-cred"
        DOCKER_CREDENTIALS_ID = "docker-cred"
        K8S_MANIFEST_REPO = "git@github.com:vinaykumarm542-max/k8s-manifest-yamls.git"
    }

    stages {
        stage('Debug PATH') {
            steps {
                sh 'echo "Jenkins PATH: $PATH"'
                sh 'which docker || echo "Docker not found"'
            }
        }

        stage('Checkout Python App Repo'){
            steps {
                git credentialsId: "${GIT_CREDENTIALS_ID}", 
                    url: 'git@github.com:vinaykumarm542-max/vinay-cicd-end-to-end.git',
                    branch: 'main'
            }
        }

        stage('Build Docker Image'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER_VAR', passwordVariable: 'DOCKER_PASS_VAR')]) {
                        sh '''
                        echo "$DOCKER_PASS_VAR" | /usr/local/bin/docker login -u $DOCKER_USER_VAR --password-stdin
                        echo 'Build Docker Image'
                        /usr/local/bin/docker build -t ${DOCKER_USER}/python-app:${IMAGE_TAG} .
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER_VAR', passwordVariable: 'DOCKER_PASS_VAR')]) {
                        sh '''
                        echo 'Push Docker Image to DockerHub'
                        /usr/local/bin/docker push ${DOCKER_USER}/python-app:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }
        
        stage('Checkout K8S Manifest Repo'){
            steps {
                git credentialsId: "${GIT_CREDENTIALS_ID}", 
                    url: "${K8S_MANIFEST_REPO}",
                    branch: 'main'
            }
        }
        
        stage('Update K8S Manifests & Push'){
            steps {
                script{
                    withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                        # Update image tag in all manifest files in deploy directory
                        for file in deploy/*.yaml; do
                            sed -i '' "s|image:.*|image: ${DOCKER_USER}/python-app:${IMAGE_TAG}|g" "$file"
                            cat "$file"
                        done

                        # Commit & push changes
                        git add deploy/*.yaml
                        git commit -m 'Updated K8S manifests with BUILD_NUMBER ${IMAGE_TAG} via Jenkins'
                        git push git@github.com:vinaykumarm542-max/k8s-manifest-yamls.git HEAD:main
                        '''                        
                    }
                }
            }
        }
    }
}
