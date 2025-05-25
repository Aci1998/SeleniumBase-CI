pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    environment {
        REPORT_DIR = '/var/www/reports'
        EXTERNAL_URL = 'http://www.wiac.xyz/reports'
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo '🔄 清空工作区并拉取代码'
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/master']],
                        extensions: [
                            [$class: 'CloneOption', depth: 1, noTags: true, shallow: true, timeout: 30],
                            [$class: 'GitLFSPull']
                        ],
                        userRemoteConfigs: [[
                            url: 'git@github.com:Aci1998/SeleniumBase-CI.git',
                            credentialsId: 'your-credentials-id' // 替换为你的 Jenkins 凭证 ID
                        ]]
                    ])

                    echo '🔍 验证 run_tests.sh 是否存在'
                    sh '''
                        echo "当前工作区内容："
                        ls -al ${WORKSPACE}
                        echo "-----------------"
                        if [ -f "${WORKSPACE}/run_tests.sh" ]; then
                            echo "✅ run_tests.sh 存在"
                        else
                            echo "❌ 错误：run_tests.sh 不存在"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo '🛠️ 使用 Docker Buildx 构建镜像...'

                    sh '''
                        echo "检查 buildx 版本:"
                        docker buildx version || echo "⚠️ buildx 未安装"
                        docker buildx ls || echo "⚠️ 无法列出 buildx 实例"

                        docker buildx build --load -t seleniumbase-test:latest .
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    echo '🚀 运行测试脚本'
                    sh '''
                        chmod +x ${WORKSPACE}/run_tests.sh
                        ${WORKSPACE}/run_tests.sh
                    '''
                }
            }
        }

        stage('Publish Report') {
            steps {
                script {
                    echo '🗂️ 获取时间戳并发布报告'
                    def timestamp = sh(script: 'date +%Y%m%d%H%M%S', returnStdout: true).trim()

                    sh "mkdir -p ${REPORT_DIR}/${timestamp}"
                    sh "cp ${WORKSPACE}/report.html ${REPORT_DIR}/${timestamp}/report.html || echo '⚠️ 未找到报告文件'"

                    publishHTML(target: [
                        reportDir: "${REPORT_DIR}/${timestamp}",
                        reportFiles: 'report.html',
                        reportName: 'HTML Report'
                    ])

                    // 暴露变量供 post 块使用
                    currentBuild.description = "Report Timestamp: ${timestamp}"
                    currentBuild.displayName = "#${env.BUILD_NUMBER} - ${timestamp}"

                    // 保存为环境变量（供 post 使用）
                    env.REPORT_TIMESTAMP = timestamp

                    echo "✅ 外部访问链接: ${EXTERNAL_URL}/${timestamp}/report.html"
                }
            }
        }
    }

    post {
        always {
            script {
                def buildStatus = currentBuild.currentResult
                def timestamp = env.REPORT_TIMESTAMP ?: 'unknown'

                echo '📧 发送邮件通知...'
                emailext(
                    subject: "测试报告 - ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                    body: """
                        <p>构建号: ${env.BUILD_NUMBER}</p>
                        <p>状态: ${buildStatus}</p>
                        <p>Jenkins 报告: <a href="${env.BUILD_URL}HTML_Report/">查看报告</a></p>
                        <p>外部访问链接: <a href="${EXTERNAL_URL}/${timestamp}/report.html">Nginx 报告链接</a></p>
                    """,
                    to: 'imacaiy@outlook.com',
                    mimeType: 'text/html'
                )
            }
        }
    }
}
