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
    parallel \
    sudo \
    vim \
    ssh \
    net-tools

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
#Set everything inside 777 for quick tweaks
RUN find /home/node/test_samples -type f -exec chmod 777 {} \;

# Use non-root user
USER node
WORKDIR $HOME

# Set env to tmpfs path
ENV WALLET /home/node/tmp/wallet.json
# Create uplads folder
RUN mkdir uploads
# Patch bashrc
RUN cat .bashrc_patch >>.bashrc

# Entrypoint
ENTRYPOINT [ "/bin/bash" ]
