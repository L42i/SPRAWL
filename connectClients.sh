#!/bin/bash

inventory_hostname=$(hostname)
base_port=4464 
ansible_play_hosts=("student1" "student2" "student3" "student4" "student5" "student6" "student7" "student8" "student9" "student10" "student11" "student12")  # List of hostnames
ipAddresses=("10.10.10.101" "10.10.10.102" "10.10.10.103" "10.10.10.104" "10.10.10.105" "10.10.10.106" "10.10.10.107" "10.10.10.108" "10.10.10.109" "10.10.10.110" "10.10.10.111" "10.10.10.112")

inventory_number=${inventory_hostname//[!0-9]/}

index=0
for item in "${ansible_play_hosts[@]}"; do
    item_number=${item//[!0-9]/}

    current_port=$((base_port + index))
    
    if (( inventory_number < item_number )); then
        echo "$inventory_hostname connects to $item on port $current_port"
        echo "${ipAddresses[index]}"
        command="jacktrip -n 1 -C ${ipAddresses[index]} -K $inventory_hostname -J $item -B $current_port &"
        
        # Execute the command
        eval $command
        
    fi

    index=$((index + 1))
done

