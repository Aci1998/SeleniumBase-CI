# 基础镜像
FROM registry.docker-cn.com/library/python:3.10-slim

# 设置环境变量
ENV LANG C.UTF-8
ENV TZ Asia/Shanghai

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    wget curl unzip gnupg ca-certificates \
    build-essential \
    libnss3 libgconf-2-4 libxi6 libxrandr2 libxcursor1 libxcomposite1 libasound2 libatk1.0-0 libgtk-3-0 \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# 安装 pip 最新版本（含 ssl）
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && rm get-pip.py

# 安装 Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# 安装 ChromeDriver（自动匹配版本）
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') && \
    DRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION) && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# 创建工作目录
WORKDIR /app

# 复制项目
COPY . /app

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 设置默认启动命令（可选）
CMD ["pytest", "--maxfail=1", "--disable-warnings"]
