# 使用国内代理拉取 python 镜像，加速构建
FROM dockerhub.m.daocloud.io/library/python:3.10-slim

# 设置环境变量
ENV LANG C.UTF-8
ENV TZ Asia/Shanghai

# 替换 apt 源为阿里云，加速依赖安装
RUN sed -i 's|http://deb.debian.org|https://mirrors.aliyun.com|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    wget curl unzip gnupg ca-certificates \
    build-essential \
    libnss3 libgconf-2-4 libxi6 libxrandr2 libxcursor1 libxcomposite1 libasound2 libatk1.0-0 libgtk-3-0 \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# 安装 pip 最新版本并配置为使用清华源
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && rm get-pip.py && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

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
