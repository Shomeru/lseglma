#!/bin/bash

# Example log:
# 11:35:23,scheduled task 032, START,37980
# 11:35:56,scheduled task 032, END,37980

# Initialize empty arrays
declare -A start_times
declare -A stop_times
declare -A job_description

# Function to convert HH:MM:SS to seconds
timestamp_to_seconds() {
  IFS=: read -r HH MM SS <<< "$1"
  # Will prefix 10# all vars to make bash interpret them in base 10
  # Hour have 3600 seconds, minute have 60 seconds
  let "result=10#$HH * 3600 + 10#$MM * 60 + 10#$SS"
  echo $result
}

# Function to display a message
# three arguments: info level + pid + message
show_message() {
  echo "$1: PID=$2 $3"
}

# Function to display job duration
job_duration() {
  local pid="$1"
  local pid_start="$2"
  local pid_end="$3"
  local duration
  
  if [[ -z $pid_start ]]; then
    pid_start=$start_times["$pid"]
  fi
  if [[ -z $pid_end ]]; then
    pid_end=$stop_times["$pid"]
  fi

  let "duration=$pid_end - $pid_start"
  
  # Check if duration
  # is longer than 5 min = 300 seconds
  # or is longer than 10 minutes = 600 seconds
  if [[ $duration -gt 600 ]]; then
    show_message "ERROR" "$pid" "${job_description[$pid]}, took longer than 10 minutes !"
  elif [[ $duration -gt 300 ]]; then
    show_message "WARNING" "$pid" "${job_description[$pid]}, took between 5 and 10 minutes !"
  fi
  
  # Remove the pid if is processed from the arrays
  # unset will not throw error
  unset 'start_times[$pid]'
  unset 'stop_times[$pid]'
  unset 'job_description[$pid]'
}

# Function to display orphan logs
orphan_log() {
for pid in "${!job_description[@]}"; do
  show_message "INFO" "$pid" "${job_description[$pid]}, missing START or END !"
done
}

# Main program
# Read the log file
# fields are sepparated by coma
# here string will remove leading spaces (read <<< "$log")
while IFS=, read -r timestamp job_desc job_status job_pid; do
  seconds=$(timestamp_to_seconds $timestamp)
  
  if [[ $job_status == " START" ]]; then
    start_times["$job_pid"]=$seconds
	job_description["$job_pid"]="$job_desc"
  elif [[ $job_status == " END" ]]; then
    # if we have start time for this job, check duration now
	# if nothing goes wrong, end time comes after start time
	# will check the exceptions at the end
	if [[ -n $start_times["$job_pid"] ]]; then
	  job_duration $job_pid ${start_times["$job_pid"]} $seconds
	else
	  # job ends without preexisting start, save value
	  stop_times["$job_pid"]=$seconds
	  job_description["$job_pid"]="$job_desc"
	fi
  fi
done <<< $(cat logs.log)

# Call function to check for orphan logs
orphan_log

# Uncomment to see more about orphaned logs
# ${!array[@]} displays keys
# ${array[@]} displays values
echo "start_times=${!start_times[@]}"
echo "stop_times=${!stop_times[@]}"
echo "job_description=${job_description[@]}"
