#!/usr/bin/env bash   
# usually we use /bin/bash, the shebang above looks for the default bash of the user (it may be installed
# in a different place other than /bin/bash)

#   $#: when used in a script it returns the number of arguments

#!/usr/bin/env bash

set -eu

function help_text {
  printf """
Deploy Express Hello world to instance(s).
Usage:
  --private-key    Private Key to use to authenticate
  --username       Username for instances to deploy to
  --hosts          Comma delimited list of hosts to deploy to.
  
Example:
  ./deploy.sh \\
    --private-key path_to_key.pem \\
    --username ubuntu \\
    --hosts 1.2.3.4,5.6.7.8
"""
}

while (("$#")); do   # while there is one or more arguments
  case "$1" in
  --private-key)
  # first argument is equal to '--private-key'
  # in this case if the second argument doesn't start with -- then it's the private key location, otherwise => error 
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      PRIVATE_KEY_LOCATION=$2  
      shift 2 ## 9adem deux fois fil arguments, after the first execution of the while loop, the third argument becomes
              ## the first and the fourth becomes the second
    else
      echo "ERROR: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --username)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      VM_USERNAME=$2    # we suppose that all the VMs have the same username
      shift 2
    else
      echo "ERROR: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --hosts)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      VM_HOSTS=$2
      shift 2
    else
      echo "ERROR: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --help)
    help_text
    exit 0
    ;;
  -* | --*=) # unsupported flags
    echo "ERROR: Unsupported flag $1" >&2
    exit 1
    ;;
  *) # preserve positional arguments
    PARAMS="$PARAMS $1" # if the argument is not a flag save it the PARAMS.  
    shift
    ;;
  esac
done

VM_HOSTS=$(echo $VM_HOSTS | tr -d " " | tr "," " ")
echo $VM_HOSTS
for INSTANCE_HOST in $VM_HOSTS; do
  echo "-- instance = $INSTANCE_HOST --"
  rsync -a -e "ssh -i $PRIVATE_KEY_LOCATION" --exclude='node_modules' app $VM_USERNAME@$INSTANCE_HOST:~
  # -a: all , -e: command to use to connect to the distant machine
  ssh -i $PRIVATE_KEY_LOCATION $VM_USERNAME@$INSTANCE_HOST "bash -s" /home/$VM_USERNAME <remote.sh 
  # execute the script remote.sh in the remote machine
done