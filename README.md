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

``docker exec -i ardrive-cli-bats -c 'cat > /home/node/tmp/wallet.json' < [path to my wallet file]``

Bear in mind that with this method, Wallet file is never written to host system.

### Automatically load wallet entities

#### On a detached setup

We need a wallet with BOTH a balance and a pre-existent Public Drive. 

The method listed below will **only** work with a [detached setup](https://github.com/ardriveapp/ardrive-bats-docker/tree/production#detached)

Using this command will not only copy our wallet inside the container, but also automatically load the public IDs for both a Drive and a Folder within the wallet into the following variables:

```$PUB_DRIVE_ID```

```$PUB_FOLD_ID```

Just copy and paste this command replacing the wallet path with yours.

```docker exec -i ardrive-cli-bats bash -c 'cat > /home/node/tmp/wallet.json' < [path to my wallet file] && docker exec -ti ardrive-cli-bats bash -c 'exec $SHELL -l'```

#### Other setups

To automatically load entities, FIRST you need to load a wallet using the method listed above on hot to [put your wallet inside a container](https://github.com/ardriveapp/ardrive-bats-docker/tree/production#put-wallet-inside-your-container)

After that, execute the following command inside the container terminal:

```exec $SHELL -l```

### Wallet Operations

There is a $WALLET variable directly pointing to /home/node/tmp/wallet.json inside the Docker.

In order to run any command that requires a wallet you could just replace its path with $WALLET

e.g. for a private file

``yarn ardrive file-info -f [file-id] -w $WALLET -p [my-unsafe-password]``


## BATS tests 

To run a single file, just use
``` bats <my-test-file.bats>```

e.g.

```bats ../test_samples//testing_hooks/hooks_sample.bats```

Recursion is supported. To run every test inside a given folder:

``` bats -r ../test_samples/``` from ```~/ardrive-cli``` will run each sample

To parallelize jobs just add ```-j <number of jobs>```

e.g. 2 jobs ```bats -r bats_test/ -j 2```

To change output format, ```-F``` plus formatter. 

Supported ones are pretty (default),tap (default w/o term), tap13 (nicer), junit (XML)

## Writing tests

For documentation regarding how to write tests, please check readme [on ardrive-cli/bats_test](https://github.com/ardriveapp/ardrive-cli/blob/master/bats_test/readme.md)

## Network tests

Disclaimer: * Might now work on MacOS *

With your ardrive-bats-docker running, in another terminal we run the following command:

```docker run -it --rm --cap-add=NET_ADMIN --net container:ardrive-cli-bats nicolaka/netshoot```

This will open a new container using the public Netshoot image that controls CLI docker network capabilities.

To see a list of every included package as well as some examples please check [Netshoot repo](https://github.com/nicolaka/netshoot#netshoot-a-docker--kubernetes-network-trouble-shooting-swiss-army-container)


## Use examples
### Redirecting Traffic

To "disable" any host, we just need to redirect its traffic.

```echo "{IP where we want to redirect} {host I want to redirect}" >> /etc/hosts```

A real example would be ```echo "0.0.0.0 http://ardrive.io" >> /etc/hosts``` to redirect all the traffic to an invalid IP (local-host)

In order to mimic/achieve different behaviors, we can use ```iproute2``` 

e.g. to get an "Unreachable" we could run this command inside Netshoot image

```ip route add unreachable <IP we redirected>```

For more examples please check [iproutes2 documentation](https://baturin.org/docs/iproute2/#ip-route-add-blackhole)

### Measure traffic

Inside Netshoot, run ```iftop``` to monitor connections and measure speeds e.g. while uploading/downloading
