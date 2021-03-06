#!/bin/bash -e

NC='\033[0m'
BOLD='\033[1m'
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BG_RED='\033[41m'
BG_YELLOW='\033[43m'
function ok() { echo -e "${GREEN}${BOLD}>>>>>>> $@${NC}"; }
function info() { echo -e "${BLUE}${BOLD}$@${NC}"; }
function warn() { echo -e "\n${BG_YELLOW}${BLACK}WARNING:${NC}${YELLOW}${BOLD} $@${NC}\n"; }
function error() { echo -e "\n${BG_RED}${BLACK}ERROR:${NC}${RED}${BOLD} $@${NC}\n\n"; }
function die() { error "$@"; exit 1; }

# PATH
export PATH="$PWD/bin:$PATH"

# TEST DIR
rm -rf tmp/test; mkdir -p tmp/test; cd tmp/test

# 1ST INDEX
mkdir 1
echo 123 > 1/123
echo 456 > 1/456
dedup index i1 1

# 2ND INDEX
mkdir -p 2
echo aaa > 2/aaa
echo bbb > 2/bbb
dedup index i2 2


function dir_should_have_no_fies()
{
  local d="$1"

  find "$d" -type d -empty -delete

  [ ! -d "$d" ] || (tree "$d" && die "$N: expected '$d' to have no files")
}

function file_should_exist()
{
    [ -e "$1" ] || die "$N: '$1' not found"
}

function file_should_not_exist()
{
    [ -e "$1" ] && die "$N: '$1' found"
}

# TEST CASES

function move_should_move_duplicates()
{
  N="MOVE should move duplicates"
  rm -rf 3 4

  mkdir 3
  echo 123 > 3/a
  echo 123 > 3/b
  echo aaa > 3/c
  echo aaa > 3/d
  echo bbb > 3/e

  dedup move 3 4 i1 i2

  dir_should_have_no_fies 3

  file_should_exist "4/3/$f/a"
  file_should_exist "4/3/$f/b"
  file_should_exist "4/3/$f/c"
  file_should_exist "4/3/$f/d"
  file_should_exist "4/3/$f/e"

  ok "$N"
}

function move_should_preserve_uniques()
{
  N="MOVE should preserve uniques"
  rm -rf 3 4

  # 3
  # ├── a
  # └── b
  mkdir 3
  echo xxx > 3/a
  echo yyy > 3/b


  dedup move 3 4 i1 i2

  dir_should_have_no_fies 4

  file_should_exist "3/$f/a"
  file_should_exist "3/$f/b"

  ok "$N"

}

function move_should_process_weird_paths()
{
  N="MOVE should process weird paths"
  local base="5 ' 6"
  rm -rf 4 "$base"

  local d="a A/b ' B"
  local f="a A ' b"

  # b\ '\ 6
  # └── a\ A
  #     └── b\ '\ B
  #         └── a\ A\ '\ b
  mkdir -p "$base/$d"
  echo 123 > "$base/$d/$f"

  dedup move "$base" 4 i1 i2

  dir_should_have_no_fies "$base"

  file_should_exist "4/$base/$d/$f"

  ok "$N"
}

function move_should_process_long_file_names()
{
  N="MOVE should process long file names"
  rm -rf 3 4

  local f="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  mkdir 3
  echo 123 > "3/$f"

  dedup move 3 4 i1 i2

  dir_should_have_no_fies 3

  file_should_exist "4/3/$f"

  ok "$N"
}

function delete_should_remove_dups()
{
  N="DELETE should remove dups"
  rm -rf 3
  mkdir 3
  echo 123 > 3/1
  echo 456 > 3/2
  echo aaa > 3/3
  echo bbb > 3/4

  dedup delete 3 i1 i2

  dir_should_have_no_fies 3

  ok "$N"
}

function delete_should_remove_weird_paths()
{
  N="DELETE should remove weird paths"
  local base="5 ' 6"
  rm -rf "$base"

  local d="a A/b ' B"
  local f="a A ' b"
  mkdir -p "$base/$d"
  echo 123 > "$base/$d/$f"

  dedup delete "$base" i1 i2

  dir_should_have_no_fies "$base"

  ok "$N"
}

function delete_should_remove_long_file_names()
{
  N="DELETE should remove logn file names"
  rm -rf 3 4

  local f="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  mkdir 3
  echo 123 > "3/$f"

  dedup delete 3 i1 i2

  dir_should_have_no_fies 3

  ok "$N"
}

info "####### MOVE"
move_should_move_duplicates
move_should_preserve_uniques
move_should_process_weird_paths
move_should_process_long_file_names

info "####### DELETE"
delete_should_remove_dups
delete_should_remove_weird_paths
delete_should_remove_long_file_names
