# 使用官方 Python 3.12.10-slim-bookworm 镜像
FROM python:3.12.10-slim-bookworm

# 设置环境变量
ENV LANG C.UTF-8
ENV TZ Asia/Shanghai

# 配置 Debian Bookworm 源为阿里云，加速依赖安装
RUN echo "deb https://mirrors.aliyun.com/debian/ bookworm main contrib non-free\n" \
    "deb https://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free\n" \
    "deb https://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free" \
    > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        unzip \
        gnupg \
        ca-certificates \
        build-essential \
        libssl-dev \
        libffi-dev \
        libnss3 \
        libgconf-2-4 \
        libxi6 \
        libxrandr2 \
        libxcursor1 \
        libxcomposite1 \
        libasound2 \
        libatk1.0-0 \
        libgtk-3-0 \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

# 安装 pip 并配置国内源
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && rm get-pip.py && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get install -y --no-install-recommends google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# 安装 ChromeDriver（改用 webdriver-manager 自动管理，无需手动安装）
# 如果你的测试代码使用 webdriver-manager 或 SeleniumBase 的自动驱动管理，这部分可以省略。

# 如果仍需手动安装固定版本，请在此处添加脚本。

# 创建工作目录并复制项目
WORKDIR /app
COPY . /app

# 安装项目依赖
RUN pip install --no-cache-dir seleniumbase && \
    pip install --no-cache-dir -r requirements.txt

# 默认命令（可根据需要替换）
CMD ["pytest", "test_case/", "--junitxml=/app/test_results.xml", "--html=/app/report.html", "--self-contained-html"]

# CMD ["pytest", "--maxfail=1", "--disable-warnings"]
