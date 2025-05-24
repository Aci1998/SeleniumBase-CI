# 使用阿里云镜像源
FROM python:3.12.10-bookworm

# 设置时区和编码
ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 替换apt源为阿里云
RUN sed -i 's|http://deb.debian.org|https://mirrors.aliyun.com|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    wget curl unzip gnupg ca-certificates \
    build-essential \
    libnss3 libgconf-2-4 libxi6 libxrandr2 libxcursor1 libxcomposite1 libasound2 libatk1.0-0 libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# 使用清华pip源
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 安装Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get install -y google-chrome-stable --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 安装匹配的ChromeDriver
RUN CHROME_VERSION=$(google-chrome --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') && \
    wget -O /tmp/chromedriver.zip \
    https://chromedriver.storage.googleapis.com/$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION%.*.*})/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /usr/local/bin/chromedriver

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["pytest", "--maxfail=1", "--disable-warnings"]
