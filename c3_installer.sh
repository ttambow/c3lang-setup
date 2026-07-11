#!/usr/bin/env bash

OPTION="$1"
USER_GROUP="$USER:$USER"

function download()
{
  local c3_localname="c3/c3c"
  local c3_remotename="c3-linux-static"
  local url="https://github.com/c3lang/c3c/releases/latest/download/$c3_remotename.tar.gz"
  
  echo "downloading latest version of $c3_remotename from $url"
  curl -L -O $url
  tar -xzf $c3_remotename.tar.gz

  local dl_version_number="$($c3_localname --version | sed -n 's/.*Version: *//p')"
  mv c3 $dl_version_number
}

function init()
{
  case "$OPTION" in
    "download")
      download ;;
    *)
       ;;
  esac
}

function main()
{
  set_latest_dir
  set_symlink "c3c"
  set_symlink "c3fmt"

  exit 0
}

function set_latest_dir()
{
  local regexp='^[0-9]+\.[0-9]+\.[0-9]+$'
  local latest_dir="$(ls -1 | grep -E "$regexp" | sort -V | tail -1)"

  echo "setting latest c3 dir to $latest_dir "
  ln -f -s "$latest_dir" latest
  
  echo "[SUDO] setting ownership of $latest_dir to $USER_GROUP "
  sudo chown $USER_GROUP $latest_dir
}

function set_symlink()
{
  local file="$1"
  local filename="c3/latest/$file"
  local localbin="/usr/local/bin"
  local symlink="$localbin/$file"
  
  echo "[SUDO] setting LOCALBIN '$(basename $symlink)' symlink to $latest... "
  sudo ln -fs "$filename" $symlink

  echo "[SUDO] setting ownership of '$(basename $symlink)' to $USER_GROUP "
  sudo chown $USER_GROUP $symlink
}

# program started here
init
main
