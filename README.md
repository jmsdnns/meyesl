# Meyesl

![An cyberspacy looking background with the words HACK THE PLANET and MEYESL written on top, with an out of place ordinary camel staring at us while standing on MEYESL](cameltheplanet.jpg)

_Meyesl is a nonblocking port scanner, written to help me learn Ocaml_ 🐪


## Using It

```shell
$ git clone https://github.com/jmsdnns/meyesl
$ cd meyesl 
$ make
$ meyesl 127.0.0.1
```

## How It Works

More elaborate usage looks like this

```shell
$ meyesl 127.0.0.1 -p 22,80,8000-8099,9999
```

### PORTS

The `-p` flag is for specifying which ports to scan. Ports can be expressed as:

* list of numbers: eyes <target> -p 22,80,1336
* range of numbers: eyes <target> -p 22-80
* mix of both: eyes <target> -p 22,80,8000-8099,443,8443,3000-3443

### TIMEOUT

The `-t` flag controls how long to wait on a connection that isn't opening before decided it's just not reachable.

The default timeout is 3 seconds.

### HELP

```shell 
$ meyesl --help
MEYESL(1)                        Meyesl Manual                       MEYESL(1)

NAME
       meyesl - A simple port scanner written in OCaml. Hack the planet.

SYNOPSIS
       meyesl [--ports=PORTS] [--timeout=TIMEOUT] [OPTION]… TARGET

ARGUMENTS
       TARGET (required)
           The target to scan.

OPTIONS
       -p PORTS, --ports=PORTS
           List of ports to scan.

       -t TIMEOUT, --timeout=TIMEOUT (absent=3.)
           Connection timeout (default is 2.0).

COMMON OPTIONS
       --help[=FMT] (default=auto)
           Show  this  help  in format FMT. The value FMT must be one of auto,
           pager, groff or plain. With auto, the  format  is  pager  or  plain
           whenever the TERM env var is dumb or undefined.

       --version
           Show version information.

EXIT STATUS
       meyesl exits with:

       0   on success.

       123 on indiscriminate errors reported on standard error.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

Meyesl v3.1415                                                       MEYESL(1)
```
