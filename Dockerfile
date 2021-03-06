# Start from the code-server Debian base image
FROM codercom/code-server:4.0.2

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json
COPY actboy168.tasks-0.9.0.vsix /home/coder/actboy168.tasks-0.9.0.vsix

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension vscjava.vscode-java-pack
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension actboy168.tasks-0.9.0.vsix

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make
RUN sudo apt-get install -y vim wget

# Install Java
RUN sudo apt-get install -y openjdk-11-jdk
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME

# Install Python
RUN sudo apt-get install -y python3 python3-pip

# Install Maven
RUN sudo apt-get -y install maven

# Install Tomcat
RUN sudo mkdir /usr/local/tomcat
RUN sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz -O /tmp/tomcat.tar.gz
RUN cd /tmp && tar xvfz tomcat.tar.gz
RUN sudo cp -Rv /tmp/apache-tomcat-9.0.50/* /usr/local/tomcat/
EXPOSE 8080

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool
# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
