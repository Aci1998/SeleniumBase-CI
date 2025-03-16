pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES') // 设置超时时间
        buildDiscarder(logRotator(numToKeepStr: '30')) // 保留最近 30 次构建记录
    }

    environment {
        // 定义环境变量
        REPORT_DIR = '/var/www/reports' // 报告存储目录
        EXTERNAL_URL = 'http://www.wiac.xyz/reports' // 外部访问 URL
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo '清空工作区并拉取代码'
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/master']],
                        extensions: [
                            [$class: 'CloneOption',
                             depth: 1,          // 只克隆最近一次提交
                             noTags: true,      // 不克隆标签
                             shallow: true,     // 启用浅克隆
                             timeout: 30        // 超时时间设置为 30 分钟
                            ],
                            [$class: 'GitLFSPull'] // 如果使用 Git LFS
                        ],
                        userRemoteConfigs: [[
                            url: 'https://github.com/Aci1998/SeleniumBase.git',
                            credentialsId: 'your-credentials-id' // 替换为 Jenkins 中配置的凭证 ID
                        ]]
                    ])

                    echo '验证文件是否存在'
                    sh '''
                        echo "当前工作区内容："
                        ls -al ${WORKSPACE}
                        echo "-----------------"
                        echo "检查 run_tests.sh 是否存在："
                        if [ -f "${WORKSPACE}/run_tests.sh" ]; then
                            echo "run_tests.sh 存在"
                        else
                            echo "错误：run_tests.sh 不存在"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    echo '赋予执行权限并运行脚本'
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
                    echo '获取时间戳'
                    def TIMESTAMP = sh(
                        script: 'date +%Y%m%d%H%M%S',
                        returnStdout: true
                    ).trim()

                    // 创建报告目录
                    sh "mkdir -p ${REPORT_DIR}/${TIMESTAMP}"

                    echo '发布 HTML 报告到 Jenkins 界面'
                    publishHTML(
                        target: [
                            reportDir: "${REPORT_DIR}/${TIMESTAMP}",
                            reportFiles: 'report.html',
                            reportName: 'HTML Report'
                        ]
                    )

                    echo '输出外部访问链接'
                    echo "外部访问链接: ${EXTERNAL_URL}/${TIMESTAMP}/report.html"
                }
            }
        }
    }

    post {
        always {
            script {
                // 获取构建状态
                def buildStatus = currentBuild.currentResult

                // 发送邮件通知
                emailext (
                    subject: "测试报告生成通知 - ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                    body: """
                        <p>构建号: ${env.BUILD_NUMBER}</p>
                        <p>状态: ${buildStatus}</p>
                        <p>Jenkins 报告: <a href="${env.BUILD_URL}HTML_Report/">查看报告</a></p>
                        <p>外部访问链接: <a href="${EXTERNAL_URL}/${env.TIMESTAMP}/report.html">Nginx 报告链接</a></p>
                    """,
                    to: 'imacaiy@outlook.com',
                    mimeType: 'text/html'
                )
            }
        }
    }
}