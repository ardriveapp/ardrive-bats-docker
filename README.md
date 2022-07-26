# Bats Docker

Docker image with every tool you need to test the Ardrive CLI with BATS.

We _strongly_ suggest to load recommended VSCode extensions for this to work with BATS

jq, GNU parallels are included. Vim is the default text editor but Nano is also included.

# Build & Run

## Build

On repo root folder:

`$ docker build . -t ardrive-bats-docker:latest `

## Run

### Interactive

Use this command to execute an interactive session and build _master_

`$ docker run --name ardrive-cli-bats --rm --init -it --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker `

To build a specific branch add this flag:

`-e BRANCH='dev'`

To disable cloning and installing, use:

`-e NO_SETUP=1`

### Detached

Run

`$ docker run --name ardrive-cli-bats --rm --init -tdi --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker && sleep 20 `

This includes a sleep of 20 seconds to ensure Docker clones and builds. Please be aware that this docker will last till you shutdown your system OR you manually stop it (docker stop ardrive-bats)

Now we can run commands inside docker. Below we run ardrive CLI on _ardrive-cli_ directory

`docker exec -w /home/node/ardrive-cli ardrive-cli-bats yarn ardrive`

To run every sample test, we just need to use

`docker exec -w /home/node/ardrive-cli ardrive-cli-bats bats -r ../test_samples/`

`-r` flag stands for recursive

And in case we want to keep the output, just pipe the content

e.g.

`docker exec -w /home/node/ardrive-cli ardrive-cli-bats bats -r ../test_samples/ | tee my.log && mv my.log BATS-test_$(date +%d-%m-%Y_%H-%S).log`

will not only put everything inside a file, but rename that file with a timestamp resulting in `BATS-test_(local-time-date).log`

### Local ENV

To load your local environment and test your local code, first we need to run the container, in this case, without setup.

`docker run --name ardrive-cli-bats --rm --init -ti -e NO_SETUP=1 --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker `

Now, in a new terminal, we just copy ardrive-cli folder

If current working directory is the repo root, we need to execute:

#### On Linux/WSL

`docker cp . ardrive-cli-bats:/home/node/ardrive-cli `

#### On MacOS ONLY

`docker cp . ardrive-cli-bats:/tmp/ardrive-cli && docker exec -i ardrive-cli-bats bash -c 'cp -r /tmp/ardrive-cli /home/node/ardrive-cli' `

Now you will have your local environment loaded into Docker. You do not need to run `yarn && yarn build `again
Every time you want to load your latest changes, just run the above command again. For a clean environment, you could always remove the ardrive-cli folder INSIDE the docker.

`rm -rf ardrive-cli `

## Interact with a wallet

Please refer to [wallets document](https://github.com/ardriveapp/ardrive-cli/blob/master/bats_test/wallets.md) on ardrive-cli/bats_test

## BATS tests

Please check [BATS Quick Guide on ardrive-cli/bats_test](https://github.com/ardriveapp/ardrive-cli/tree/master/bats_test#quick-guide)

## Writing tests

For documentation regarding how to write tests, please check readme [on ardrive-cli/bats_test](https://github.com/ardriveapp/ardrive-cli/blob/master/bats_test/readme.md)

## Network tests

Please check networking documentation [on ardrive-cli/bats_test](https://github.com/ardriveapp/ardrive-cli/blob/master/bats_test/network_tools.md)

## Writing tests and BATS

For documentation about BATS, please check readme [on ardrive-cli/bats_test](https://github.com/ardriveapp/ardrive-cli/blob/master/bats_test/readme.md)
