# dev

A utility to develop on a local kubernetes cluster.

## Installation

Dump the `dev.sh` inside your `PATH` and you should be good
to go.

```console
$ dev help
List of all available commands:

 * check
 * exec
 * help
 * in
 * test
 * up
```

## Extending

You can add your own functionalities / commands by including
this script into your own. You simply need to declare your 
own custom commands following the `cmd_$command` convention
and then source `dev.sh`:

```shell
#!/bin/bash
cmd_version(){
    echo "Not really stable..."
}

source ./dev.sh
```

Then, your custom commands will be available:

```console
$ dev version
Not really stable...
```

Note that you will need to alias `dev` to your own custom script.