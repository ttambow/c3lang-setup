#!/usr/bin/env bash

LOCALBIN="/usr/local/bin"
C3DIR="$LOCALBIN/c3"

MESSAGE_DOWNLOAD_AVAILABLE="new c3 version available"
MESSAGE_LATEST_INSTALLED="latest c3 already installed"
MESSAGE_MISSING_C3DIR="$C3DIR is missing, creating directory"

function change_owner()
{
  local path="$1"
  local user_group="$USER:$USER"

  echo "[SUDO] setting ownership of '$path' to $user_group "
  sudo chown "$user_group" "$path"
}

function check_latest()
{
  local url="https://api.github.com/repos/c3lang/c3c/releases/latest"
  local remote_version="$(curl -s $url | jq -r '.tag_name' | sed 's/v//')"
  
  [[ -d "$C3DIR/$remote_version" ]] \
    && echo "$MESSAGE_LATEST_INSTALLED: $remote_version" \
    || echo "$MESSAGE_DOWNLOAD_AVAILABLE: $remote_version"
}

function download()
{
  local response="$(check_latest)"
  local response_message="${response%:*}"
  local remote_version="${response##*: }"

  echo -e "remote response: '$response'\nmessage: '$response_message'\nversion: '$remote_version'"

  [[ "$MESSAGE_LATEST_INSTALLED" == "$response_message" ]] \
    && echo "$response" && exit 

  local download_dir="/tmp/download"

  [[ ! -d "$download_dir" ]] \
    && mkdir -p "$download_dir"

  cd "$download_dir" || exit

  local c3_remotename="c3-linux-static"
  local url="https://github.com/c3lang/c3c/releases/latest/download/$c3_remotename.tar.gz"

  echo "downloading latest version of $c3_remotename from $url "
  
  curl -L -O "$url"
  tar -xzf "$c3_remotename.tar.gz"
  
  local dl_version_number="$(c3/c3c --version | sed -n 's/.*Version: *//p')"
  
  sudo mv -f c3 "$C3DIR/$remote_version"

  cd "$C3DIR" || exit
  rm -rf "$download_dir"
}

function init()
{
  local option="$1"
  echo "starting $0 at $(date)"

  prerequisites

  case "$option" in
    "download")
      download
      ;;
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

function prerequisites()
{
  [[ ! -d "$C3DIR" ]] \
    && echo "$MESSAGE_MISSING_C3DIR" \
    && sudo mkdir -p "$C3DIR" \
    && change_owner "$C3DIR"
}

function set_latest_dir()
{
  cd "$C3DIR" || exit

  local regexp='^[0-9]+\.[0-9]+\.[0-9]+$'
  local latest_dir="$(ls -1 | grep -E "$regexp" | sort -V | tail -1)"

  echo "setting latest c3 dir to $latest_dir "
  link_file "$latest_dir" latest

  change_owner "$latest_dir"

  echo "[SUDO] enabling execution for c3c and c3fmt in $latest_dir "
  sudo chmod +x "$latest_dir/c3c" "$latest_dir/c3fmt" 
}

function link_file()
{
  local file="$1"
  local symlink="$2"
  
  echo "[SUDO] setting symlink $symlink to $filename"
  sudo ln -fs "$file" "$symlink"
}

function set_symlink()
{
  local file="$1"
  local filename="$C3DIR/latest/$file"
  local symlink="$LOCALBIN/$file"
  
  link_file "$filename" "$symlink"

  change_owner "$symlink"
}

# program started here
init "$1"
main
