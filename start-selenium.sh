#!/bin/bash

# Start the Selenium server with correct parameters
java -jar /opt/selenium/selenium-server.jar standalone --port 4444 &

# Keep the container running
tail -f /dev/null
