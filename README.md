# c3lang-setup
helper(s) for installing and setting up c3lang. 

only tested on linux.

i think i broke it trying to make work with freebsd as well. will return to this later...

## install
### download and install

```shell
  curl -L -O https://github.com/ttambow/c3lang-setup/raw/refs/heads/main/c3-setup.sh | bash
```

#### C3C_LIB environment variable

update your profile with (i.e., .shrc): 

```shell
export C3C_LIB="/usr/local/bin/c3/latest/lib"
```

## crontab
add the following to crontab (example schedule)

```
# check for new versions of c3, on the 18th of every month
20  4  18  *  *    /usr/local/bin/c3/setup.sh download

```

# appendix
* [c3lang/c3c/releases](https://github.com/c3lang/c3c/releases)
