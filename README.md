# Bats Docker

We *strongly* suggest to load recommended VSCode extensions for this to work with BATS

jq, GNU parallels are included. Vim is the default text editor.
## Build & Run

### Build

On repo root folder:

```$ docker build . -t ardrive-bats-docker:latest      ```                                                                  

### Run

### Interactive

Use this command to execute an interactive session and build *master*

```$ docker run --name ardrive-bats --rm --init -it --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker   ```

To build a specific branch add this flag:

``` -e BRANCH='dev' ```

To disable cloning and installing, use:

``` -e NO_SETUP=1 ```

Please check Ardrive CLI Docker [readme](https://github.com/ardriveapp/ardrive-cli-docker/blob/production/README.md#run-ardrive-cli-docker) for MORE options and wallet interactions

### Detached

Run

```$ docker run --name ardrive-bats --rm --init -td --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker && sleep 20 ```

This includes a sleep of 20 seconds to ensure Docker clones and builds. Please be aware that this docker will last till you shutdown your system OR you manually stop it (docker stop ardrive-bats)

Now we can run commands inside docker. Below we run ardrive CLI on *ardrive-cli* directory

```docker exec -w /home/node/ardrive-cli ardrive-bats yarn ardrive```

To run every sample test, we just need to use

```docker exec -w /home/node/ardrive-cli ardrive-bats bats -r ../test_samples/```

```-r``` flag stands for recursive

And in case we want to keep the output, just pipe the content

e.g.

```docker exec -w /home/node/ardrive-cli ardrive-bats bats -r ../test_samples/ | tee my.log && mv my.log BATS-test_$(date +%d-%m-%Y_%H-%S).log```

will not only put everything inside a file, but rename that file with a timestamp resulting in ```BATS-test_(local-time-date).log```

### Local ENV

To load your local environment and test you local code, first we need to run the container, in this case, without setup.

```docker run --name ardrive-cli-bats --rm --init -ti -e NO_SETUP=1 --mount type=tmpfs,destination=/home/node/tmp ardrive-bats-docker   ```

Now, in a new terminal, we just copy ardrive-cli folder

If current working directory is the repo root, we need to execute:

```docker cp . ardrive-cli-bats:/home/node/ardrive-cli ```

Now you will have you local environment loaded into Docker.
Every time you want to load your latest changes, just run the above command again.
## BATS tests 

To run a single file, just use
``` bats <my-test-file.bats>```

Globs are supported. To run every test inside a given folder:

``` bats ../test_samples/*``` from ```~/ardrive-cli``` will run each sample

To parallelize jobs just add ```-j <number of jobs>```

To change output format, ```-F``` plus formatter. 

Supported ones are pretty (default),tap (default w/o term), tap13 (nicer), junit (XML)
### Globals

There are several global variables you can use to introspect on Bats tests:

- $BATS_TEST_FILENAME is the fully expanded path to the Bats test file.

- $BATS_TEST_DIRNAME is the directory in which the Bats test file is located.

- $BATS_TEST_NAMES is an array of function names for each test case.

- $BATS_TEST_NAME is the name of the function containing the current test case.

- $BATS_TEST_DESCRIPTION is the description of the current test case.

- $BATS_TEST_NUMBER is the (1-based) index of the current test case in the test file.

- $BATS_TMPDIR is the location to a directory that may be used to store temporary files.

- $BATS_RUN_COMMAND string contains the command and command arguments passed to *run* 
  
Check every variable [here](https://bats-core.readthedocs.io/en/stable/writing-tests.html#special-variables)
### Support libs

[Support](https://github.com/bats-core/bats-support#bats-support)

[Files](https://github.com/bats-core/bats-file#index-of-all-functions)

[Assertions](https://github.com/bats-core/bats-assert#usage)


### Basic Commands

#### Log to console

Always  ``` echo 'text' >&3 ```

Only on failures ```echo 'text' ```

#### Assertions and running commands

Use *run*. It will execute commands in a sub-shell. Can execute scripts as well.

```
@test "invoking foo with a nonexistent file prints an error" {
  run -1 foo nonexistent_filename
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}
```

```run``` alongside ```-1``` fails if status is not 1. We can replace that number for any number we want to check any exit code.

```$output``` is how we check the complete input of a command

``` [ "$output" = "<Check output form run here>" ]``` 

```[ "${lines[0]}" = "Line output here" ]``` is how we check a specific line. In this case, line 0.

Please check complete BATS docs [here](https://bats-core.readthedocs.io/en/stable/index.html)

There are also many examples on [test_samples](https://github.com/ardriveapp/ardrive-bats-docker/tree/production/test_samples) folder
 