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
RUN mkdir -p ~/.lara-stacker/scripts/helpers
RUN mkdir -p ~/.lara-stacker/files/.vscode
RUN mkdir -p ~/.lara-stacker/files/.opinionated
RUN mkdir -p ~/.lara-stacker/files/.shared
COPY .env.test ~/.lara-stacker/.env
COPY lara-stacker.sh ~/.lara-stacker/lara-stacker.sh
COPY scripts/setup.sh ~/.lara-stacker/scripts/setup.sh
COPY scripts/helpers/permit.sh ~/.lara-stacker/scripts/helpers/permit.sh
COPY files/.vscode/settings.json ~/.lara-stacker/files/.vscode/settings.json
COPY files/.opinionated/keybindings.json ~/.lara-stacker/files/.opinionated/keybindings.json
COPY files/.shared/phpcs.xml ~/.lara-stacker/files/.shared/phpcs.xml

# Make the script executable
WORKDIR ~/.lara-stacker
RUN sudo chmod +x ./lara-stacker.sh
RUN sudo chmod +x ./scripts/setup.sh
RUN sudo chmod +x ./scripts/helpers/permit.sh

# Run the setup script (0)
RUN sudo ./lara-stacker.sh 0
