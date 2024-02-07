#!/bin/bash

# Function to greet all users
greet_all_users() {
    for user in "${sudo_users[@]}"; do
        echo "Warm greetings, $user!"
        echo "$(date +"%Y-%m-%d %T"): Greeted sudoer $user" >> greeting_log.txt
    done
    for user in "${normal_users[@]}"; do
        echo "Hello, $user!"
        echo "$(date +"%Y-%m-%d %T"): Greeted $user" >> greeting_log.txt
    done
}

# Function to list standard users
list_normal_users() {
    echo "List of normal users:"
    for user in "${normal_users[@]}"; do
        echo "$user"
    done
	echo "$(date +"%Y-%m-%d %T"): Listed all users" >> greeting_log.txt
}

# Function to read the log file
read_log_file() {
    echo "Reading log file:"
    tail -n 20 greeting_log.txt
	echo "$(date +"%Y-%m-%d %T"): Read log" >> greeting_log.txt
}

# Function to list which users have sudo
list_sudo_users() {
    echo "Users with sudo privileges:"
    for user in "${sudo_users[@]}"; do
        echo "$user"
    done
	echo "$(date +"%Y-%m-%d %T"): Listed sudo users" >> greeting_log.txt
}

# Function to greet specified users
greet_specified_users() {
    for user in "$@"; do
        if [[ " ${normal_users[@]} " =~ " $user " ]]; then
            echo "Hello, $user!"
            echo "$(date +"%Y-%m-%d %T"): Greeted specified user $user" >> greeting_log.txt
        elif [[ " ${sudo_users[@]} " =~ " $user " ]]; then
            echo "Warm greetings, $user!"
            echo "$(date +"%Y-%m-%d %T"): Greeted specified sudoer $user" >> greeting_log.txt
		else
            echo "User $user not found or does not have login shell."
			echo "$(date +"%Y-%m-%d %T"): Tried to greet specified user $user but $user wasn't found/has no login shell" >> greeting_log.txt
        fi
    done
}

# Function to show help
help_function() {
	echo "The following options exist:"
	echo " -a				Greet all users"
	echo " -l				List normal users"
	echo " -s <users>			Greet specified users"
	echo " -c				Check sudoers"
	echo " -h				This help menu"
	echo " --rl				Print the last 20 lines of the log"
	echo " "
	echo " Additionally the script can be run without options to enter the names in situ"
	echo " "
}

# Log on run
echo " " >> greeting_log.txt
echo "$(date +"%Y-%m-%d %T"): 	=== Greeter Run ===" >> greeting_log.txt

# Load users from passwd file into array and sudoers into a seperate one
normal_users=()
sudo_users=()

while IFS=':' read -r username _ uid gid _ home shell; do
    if [[ "$shell" != "/bin/nologin" && "$shell" != "/usr/bin/nologin" ]]; then
        if sudo -lU "$username" | grep -q "(ALL : ALL) ALL"; then
            sudo_users+=("$username")
			echo "$(date +"%Y-%m-%d %T"): Added sudoer $username to sudo_users array" >> greeting_log.txt
		else
			normal_users+=("$username")
			echo "$(date +"%Y-%m-%d %T"): Added user $username to normal_users array" >> greeting_log.txt
        fi
    fi
done < /etc/passwd

# Main
if [[ $# -gt 0 ]]; then
    case $1 in
        -a)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -a/greet all argument ===" >> greeting_log.txt
            greet_all_users
            ;;
        -l)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -l/list users argument ===" >> greeting_log.txt
            list_normal_users
            ;;
        --rl)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with --rl/read log argument ===" >> greeting_log.txt
            read_log_file
            ;;
        -c)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -c/check sudo users argument ===" >> greeting_log.txt
            list_sudo_users
            ;;
        -h)
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -h, showing help ===" >> greeting_log.txt
			help_function
            ;;
        -s)
            shift
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with -s/specific users argument with the following $@ ===" >> greeting_log.txt
            greet_specified_users "$@"
            ;;
        *)
            echo "Invalid argument: $1. Try -h for help"
			echo "$(date +"%Y-%m-%d %T"): === Greeter was run with an invalid argument ===" >> greeting_log.txt
            ;;
    esac
else # Execute cli if no arguments given
	echo "$(date +"%Y-%m-%d %T"): === Greeter was run without arguments, executing cli for selection of users to greet ===" >> greeting_log.txt
	read -rp "No argument given, please enter users to greet: " input_usernames
	usernames=($input_usernames)
    greet_specified_users "${usernames[@]}"
fi