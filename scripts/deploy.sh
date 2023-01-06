#!/bin/bash

# causes bash to exit immediately if any command returns a non-zero exit status or if it tries to use an unset variable
set -eu

# Print usage information if the -h flag is passed
while getopts ":h" opt; do
  case ${opt} in
    h )
      echo "Usage: ./deploy.sh [-h] [profile]"
      echo ""
      echo "Options:"
      echo "  -h           Show this help message"
      echo ""
      echo "Arguments:"
      echo "  profile      The protostar profile to use (default: devnet)"
      exit 0
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Determine the absolute path of the entry point script
entry_point_path=$(dirname "$(readlink -f "$0")")

profile=${1:-"devnet"}

build_dir=./build
deployment_cache_file=./deploys.json

. "$entry_point_path/helpers.sh"

ensure_deployment_cache $deployment_cache_file

contract_list=("world" "location_component" "move_system")

for contract_name in "${contract_list[@]}"; do
    if [ "$contract_name" != "world" ]; then
	      # we need to pass deployment the operative world contract
	      deployed_world_address=$(jq -r ".$profile.world" $deployment_cache_file)
	      if [ "$deployed_world_address" = "null" ]; then
		        # If the variable is empty, print an error message and exit the script
		        echo "Must have world contract for given profile ($profile) to deploy $contract_name):"
		        exit 1
            
	      fi
        
	      deploy_protostar $contract_name $deployed_world_address
	      update_json_value $profile $contract_name $deployed_address $deployment_cache_file

    else
	      # In the case of world, we have no init values to pass to the constructor
	      deploy_protostar $contract_name ""
	      update_json_value $profile $contract_name $deployed_address $deployment_cache_file
    fi
done

