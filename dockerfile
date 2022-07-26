FROM node:17-bullseye as builder

# Install bats
COPY package.json /home/node/packages/
WORKDIR /home/node/packages/
RUN yarn

FROM node:17-bullseye
# Install packages
RUN apt-get update
RUN apt-get install --no-install-recommends -y \
    git \
    jq \
    iputils-ping \
    nano \
    nmap \
    parallel \
    sudo \
    vim

# Clear apt cache
RUN apt-get clean -y

# Set password and sudo
ARG PASSWORD=ardrive
RUN echo "root:${PASSWORD}" | chpasswd
RUN echo "node:${PASSWORD}" | chpasswd
RUN adduser node sudo
#Set home var
ENV HOME /home/node

# Copy scripts
COPY scripts/gitClone.sh /home/node/
RUN chmod +x /home/node/gitClone.sh
COPY scripts/yarnInstall.sh /home/node/
RUN chmod +x /home/node/yarnInstall.sh
COPY scripts/entry.sh /home/node/
RUN chmod +x /home/node/entry.sh
COPY scripts/.bashrc_patch /home/node/
RUN chmod +r /home/node/.bashrc_patch

# Bats from builder

# Node bin
COPY --from=builder /home/node/packages/node_modules/.bin /home/node/packages/node_modules/.bin

# Bats Core
COPY --from=builder /home/node/packages/node_modules/bats/bin /home/node/packages/node_modules/bats/bin
COPY --from=builder /home/node/packages/node_modules/bats/lib /home/node/packages/node_modules/bats/lib
COPY --from=builder /home/node/packages/node_modules/bats/libexec /home/node/packages/node_modules/bats/libexec

# Plugins

# Assert
COPY --from=builder /home/node/packages/node_modules/bats-assert/load.bash /home/node/packages/node_modules/bats-assert/load.bash
COPY --from=builder /home/node/packages/node_modules/bats-assert/src /home/node/packages/node_modules/bats-assert/src
COPY --from=builder /home/node/packages/node_modules/bats-assert/node_modules /home/node/packages/node_modules/bats-assert/node_modules

# Files
COPY --from=builder /home/node/packages/node_modules/bats-file/load.bash /home/node/packages/node_modules/bats-file/load.bash
COPY --from=builder /home/node/packages/node_modules/bats-file/src /home/node/packages/node_modules/bats-file/src

# Support
COPY --from=builder /home/node/packages/node_modules/bats-support/load.bash /home/node/packages/node_modules/bats-support/load.bash
COPY --from=builder /home/node/packages/node_modules/bats-support/src /home/node/packages/node_modules/bats-support/src
COPY --from=builder /home/node/packages/node_modules/bats-support/node_modules /home/node/packages/node_modules/bats-support/node_modules

# Add bats to path
ENV PATH="/home/node/packages/node_modules/.bin:${PATH}"

# Fetch examples
COPY test_samples/ /home/node/test_samples
#Set everything inside 755 for quick tweaks
RUN find /home/node/test_samples -type f -exec chmod 755 {} \;
#Set everything inside Node tmp to 777
RUN mkdir /home/node/tmp
RUN chmod 777 /home/node/tmp

# Copy Arlocal
COPY arlocal /home/node/arlocal
# Enable magic script
RUN chmod +x /home/node/arlocal/magic.sh
# Set Node as owner of each directory inside Arlocal
RUN find /home/node/arlocal -type d -exec chown node:node {} \;
# Set Node as owner of each file inside Arlocal
RUN find /home/node/arlocal -type f -exec chown node:node {} \;

# Use non-root user
USER node
WORKDIR $HOME

# Set env to tmpfs path
ENV WALLET /home/node/tmp/wallet.json

# TODO review if we need these at all
# Set testing ENV variables to sample IDs
ENV PUB_DRIVE_ID "00000000-0000-0000-0000-000000000000"
ENV ROOT_FOLDER_ID "11111111-1111-1111-1111-111111111111"
ENV PUB_FILE_ID "22222222-2222-2222-2222-222222222222"
ENV PUB_FILE_SIZE "0"
ENV PUB_FILE_NAME "foo"
ENV PARENT_FOLDER_ID "33333333-3333-3333-3333-333333333333"

# Create uplads folder
RUN mkdir uploads
# Patch bashrc
RUN cat .bashrc_patch >>.bashrc

# Entrypoint
ENTRYPOINT [ "/bin/bash" ]
