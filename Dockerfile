# Use an ARM-compatible base image
FROM debian:bullseye-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y wget gnupg2 unzip curl apt-transport-https ca-certificates software-properties-common

# Install OpenJDK 11
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless

# Install Python 3.9 and pip
RUN apt-get update && \
    apt-get install -y python3.9 python3-pip

# Install Chromium and Chromedriver
RUN apt-get update && \
    apt-get install -y chromium chromium-driver

# Download Selenium server standalone
RUN mkdir -p /opt/selenium && \
    wget -O /opt/selenium/selenium-server.jar https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.1.0/selenium-server-4.1.0.jar

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Copy the current directory contents into the container at /app
COPY . /app

# Set the working directory to /app
WORKDIR /app

# Copy the custom start script
COPY start-selenium.sh /app/start-selenium.sh

# Make the script executable
RUN chmod +x /app/start-selenium.sh

# Define environment variable
ENV PYTHONPATH=/app

# Run the custom start script
CMD ["/app/start-selenium.sh"]
