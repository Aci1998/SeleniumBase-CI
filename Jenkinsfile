pipeline {
    agent any
    environment {
        IMAGE_NAME = 'seleniumbase-test:latest'
        DOCKER_BUILDKIT = '1'  // 启用 BuildKit
    }
    stages {
        stage('Checkout') {
            steps {
                git credentialsId: '92de817e-eb61-46f8-83d9-47972d8dce12', url: 'git@github.com:Aci1998/SeleniumBase-CI.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🛠️ 开始构建 Docker 镜像...'
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Run Tests') {
            steps {
                echo '🚀 运行测试...'
                sh 'docker run --rm $IMAGE_NAME'
            }
        }
    }

    post {
        failure {
            mail to: 'imacaiy@outlook.com',
                 subject: "🚨 Jenkins构建失败：${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "请检查 Jenkins 构建日志。\n项目: ${env.JOB_NAME}\n编号: ${env.BUILD_NUMBER}\nURL: ${env.BUILD_URL}"
        }
    }
}
