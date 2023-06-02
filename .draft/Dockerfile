FROM ubuntu:latest

# Set up tzdata to avoid the prompt
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install sudo
RUN apt-get update && \
    apt-get install -y sudo

# create a user    
RUN useradd -m stacker && \
    usermod -aG sudo stacker && \
    echo "stacker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER stacker

# Copy the scripts into the container
RUN mkdir -p ~/.tall-stacker/scripts/helpers
RUN mkdir -p ~/.tall-stacker/files/.vscode
RUN mkdir -p ~/.tall-stacker/files/.opinionated
RUN mkdir -p ~/.tall-stacker/files/.shared
COPY .env.test ~/.tall-stacker/.env
COPY tall-stacker.sh ~/.tall-stacker/tall-stacker.sh
COPY scripts/setup.sh ~/.tall-stacker/scripts/setup.sh
COPY scripts/helpers/permit.sh ~/.tall-stacker/scripts/helpers/permit.sh
COPY files/.vscode/settings.json ~/.tall-stacker/files/.vscode/settings.json
COPY files/.opinionated/keybindings.json ~/.tall-stacker/files/.opinionated/keybindings.json
COPY files/.shared/phpcs.xml ~/.tall-stacker/files/.shared/phpcs.xml

# Make the script executable
WORKDIR ~/.tall-stacker
RUN sudo chmod +x ./tall-stacker.sh
RUN sudo chmod +x ./scripts/setup.sh
RUN sudo chmod +x ./scripts/helpers/permit.sh

# Run the setup script (0)
RUN sudo ./tall-stacker.sh 0
