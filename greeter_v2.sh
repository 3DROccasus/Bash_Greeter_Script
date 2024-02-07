#!/bin/bash

# Function to greet all users
greet_all_users() {
    for user in "${all_users[@]}"; do
        echo "Hello, $user!"
        echo "$(date +"%Y-%m-%d %T"): Greeted $user" >> greeting_log.txt
    done
}

# Function to list users from array
list_users() {
    echo "List of users:"
    for user in "${all_users[@]}"; do
        echo "$user"
    done
	echo "$(date +"%Y-%m-%d %T"): Listed all users" >> greeting_log.txt
}

# Function to read the log file
read_log_file() {
    echo "Reading log file:"
    cat greeting_log.txt
	echo "$(date +"%Y-%m-%d %T"): Read log" >> greeting_log.txt
}

# Function to list which users have sudo
check_sudo_users() {
    echo "Users with sudo privileges:"
    for user in "${sudo_users[@]}"; do
        echo "$user"
    done
	echo "$(date +"%Y-%m-%d %T"): Listed sudo users" >> greeting_log.txt
}

# Function to greet specified users
greet_specified_users() {
    for user in "$@"; do
        if [[ " ${all_users[@]} " =~ " $user " ]]; then
            echo "Hello, $user!"
            echo "$(date +"%Y-%m-%d %T"): Greeted specified user $user" >> greeting_log.txt
        else
            echo "User $user not found or does not have login shell."
			echo "$(date +"%Y-%m-%d %T"): Tried to greet specified user $user but $user wasn't found/has no login shell" >> greeting_log.txt
        fi
    done
}

# Log on run
echo " " >> greeting_log.txt
echo "$(date +"%Y-%m-%d %T"): 	=== Greeter Run ===" >> greeting_log.txt

# Load users from passwd file into array and sudoers into a special one
all_users=()
sudo_users=()

while IFS=':' read -r username _ uid gid _ home shell; do
    if [[ "$shell" != "/bin/nologin" && "$shell" != "/usr/bin/nologin" ]]; then
        all_users+=("$username")
		echo "$(date +"%Y-%m-%d %T"): Added user $username to all_users array" >> greeting_log.txt
        if sudo -lU "$username" | grep -q "(ALL : ALL) ALL"; then
            sudo_users+=("$username")
			echo "$(date +"%Y-%m-%d %T"): Added sudoer $username to sudo_users array" >> greeting_log.txt
        fi
    fi
done < /etc/passwd

# Main
if [[ $# -gt 0 ]]; do
    case $1 in
        -a)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -a/greet all argument ===" >> greeting_log.txt
            greet_all_users
            ;;
        -l)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -l/list users argument ===" >> greeting_log.txt
            list_users
            ;;
        --rl)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with --rl/read log argument ===" >> greeting_log.txt
            read_log_file
            ;;
        -c)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -c/check sudo users argument ===" >> greeting_log.txt
            check_sudo_users
            ;;
        -s)
            shift
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -s/specific users argument with the following $@ ===" >> greeting_log.txt
            greet_specified_users "$@"
            ;;
        *)
            echo "Invalid argument: $1"
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with an invalid argument ===" >> greeting_log.txt
            ;;
    esac
    shift
else
