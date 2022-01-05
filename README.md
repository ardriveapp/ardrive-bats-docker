# Bats Docker

Docker image with every tool you need to test the Ardrive CLI with BATS.

We *strongly* suggest to load recommended VSCode extensions for this to work with BATS

jq, GNU parallels are included. Vim is the default text editor but Nano is also included.
# Build & Run

## Build

On repo root folder:

```$ docker build . -t ardrive-bats-docker:latest      ```                                                                  

## Run

### Interactive

Use this command to execute an interactive session and build *master*

```$ docker run --name ardrive-cli-bats --rm --init -it --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker   ```

To build a specific branch add this flag:

``` -e BRANCH='dev' ```

To disable cloning and installing, use:

``` -e NO_SETUP=1 ```

### Detached

Run

```$ docker run --name ardrive-cli-bats --rm --init -tdi --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker && sleep 20 ```

This includes a sleep of 20 seconds to ensure Docker clones and builds. Please be aware that this docker will last till you shutdown your system OR you manually stop it (docker stop ardrive-bats)

Now we can run commands inside docker. Below we run ardrive CLI on *ardrive-cli* directory

```docker exec -w /home/node/ardrive-cli ardrive-cli-bats yarn ardrive```

To run every sample test, we just need to use

```docker exec -w /home/node/ardrive-cli ardrive-cli-bats bats -r ../test_samples/```

```-r``` flag stands for recursive

And in case we want to keep the output, just pipe the content

e.g.

```docker exec -w /home/node/ardrive-cli ardrive-cli-bats bats -r ../test_samples/ | tee my.log && mv my.log BATS-test_$(date +%d-%m-%Y_%H-%S).log```

will not only put everything inside a file, but rename that file with a timestamp resulting in ```BATS-test_(local-time-date).log```

### Local ENV

To load your local environment and test your local code, first we need to run the container, in this case, without setup.

```docker run --name ardrive-cli-bats --rm --init -ti -e NO_SETUP=1 --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker   ```

Now, in a new terminal, we just copy ardrive-cli folder

If current working directory is the repo root, we need to execute:

```docker cp . ardrive-cli-bats:/home/node/ardrive-cli ```

Now you will have you local environment loaded into Docker. You do not need to run ```yarn && yarn build ```again
Every time you want to load your latest changes, just run the above command again. For a clean environment, you could always remove the ardrive-cli folder INSIDE the docker. 

```rm -rf ardrive-cli ```

## Interact with a wallet

### Put wallet inside your container

To copy our wallet inside Docker, we just need the following command.
Image was intended to work with only ONE wallet at a time. 

Running the below command a 2nd time will overwrite the 1st wallet.

``docker exec -i ardrive-cli-bats bash -c 'cat > /home/node/tmp/wallet.json' < [path to my wallet file]``

Bear in mind that with this method, Wallet file is never written to host system.
### Wallet Operations

There is a $WALLET variable directly pointing to /home/node/tmp/wallet.json inside the Docker.

In order to run any command that requires a wallet you could just replace its path with $WALLET

e.g. for a private file

``yarn ardrive file-info -f [file-id] -w $WALLET -p [my-unsafe-password]``

## Writing tests and BATS

For documentation about BATS, please check readme [on ardrive-cli/bats_test](https://github.com/ardriveapp/ardrive-cli/blob/master/bats_test/readme.md)
