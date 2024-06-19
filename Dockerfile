# Use the official Python image
FROM python:3.8-slim

# Install necessary packages and dependencies for Google Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install && \
    rm google-chrome-stable_current_amd64.deb

# Detect the architecture and ChromeDriver version
RUN arch=$(dpkg --print-architecture) && \
    echo "Detected architecture: $arch" && \
    echo $arch > /arch.txt && \
    CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    echo "ChromeDriver version: $CHROMEDRIVER_VERSION" && \
    echo $CHROMEDRIVER_VERSION > /chromedriver_version.txt

# Download ChromeDriver for amd64
RUN arch=$(cat /arch.txt) && \
    CHROMEDRIVER_VERSION=$(cat /chromedriver_version.txt) && \
    echo "Downloading ChromeDriver for amd64, version: $CHROMEDRIVER_VERSION" && \
    wget -N https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip

# Download ChromeDriver for arm64
RUN arch=$(cat /arch.txt) && \
    CHROMEDRIVER_VERSION=$(cat /chromedriver_version.txt) && \
    echo "Downloading ChromeDriver for arm64, version: $CHROMEDRIVER_VERSION" && \
    wget -N https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux_arm64.zip

# Unzip and install ChromeDriver for amd64
RUN arch=$(cat /arch.txt) && \
    if [ "$arch" = "amd64" ]; then \
        echo "Unzipping ChromeDriver for amd64" && \
        unzip chromedriver_linux64.zip && \
        mv chromedriver /usr/bin/chromedriver && \
        rm chromedriver_linux64.zip; \
    fi

# Unzip and install ChromeDriver for arm64
RUN arch=$(cat /arch.txt) && \
    if [ "$arch" = "arm64" ]; then \
        echo "Unzipping ChromeDriver for arm64" && \
        unzip chromedriver_linux_arm64.zip && \
        mv chromedriver /usr/bin/chromedriver && \
        rm chromedriver_linux_arm64.zip; \
    fi

# Set permissions for ChromeDriver
RUN chown root:root /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver

# Copy the requirements.txt file and install Python dependencies
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN echo "Contents of requirements.txt:" && cat requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Selenium script
COPY youtubepull.py /app/youtubepull.py

# Set the entry point to run the Python script
ENTRYPOINT ["python", "youtubepull.py"]
