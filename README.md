# lseglma
  - Candidate: **Adrian Stoica**
  - Date: **15 May 2025**

## Coding Challenge
Log Monitoring ApplicationThis task should take at most 90 minutes of your time, focus on problem solving and good
coding practices. If you run out of time, then please document what else you would have liked
to have achieved. You can complete this challenge in any common programming language.
You are provided with a log file, logs.log. The goal of this challenge is to build a log monitoring
application that reads the file, measures how long each job takes from start to finish and
generates warnings or errors if the processing time exceeds certain thresholds.

## Your application should be able to:
1. Parse the CSV log file.
2. Identify each job or task and track its start and finish times.
3. Calculate the duration of each job from the time it started to the time it finished.
4. Produce a report or output that:
- Logs a warning if a job took longer than 5 minutes.
- Logs an error if a job took longer than 10 minutes.

## Log Structure:
- HH:MM:SS is a timestamp in hours, minutes, and seconds.
- The job description.
- Each log entry is either the “START” or “END” of a process.
- Each job has a PID associated with it e.g., 46578.

## What we are looking for:
- Clean, readable, and well-structured code.
- Include comments to explain any tricky parts.
- Commit changes with clear and descriptive commit messages to illustrate your
development process.
- Suitable testing.
- A brief README.

## Submission:
- Create a public repository on GitHub containing your source code, tests, documentation
and output/log file.
- Provide a link to your repository as proof of completion.

# Documentation

## Assumption:
- all jobs have unique pid.
- log lines are ordered by timestamp
- the first log from a job is always "START"
- there can be orphaned jobs (missing "START" or "END") 

## Initialize empty arrays
Bash supports indexed (ex: myarr[0]) and associative arrays (ex: myarr['key']).
We must use associative arrays to store:
- pid & job description
- pid & start time
- pid & stop time

## How it works
We are going to loop over the lines in the log file, and we are going to populate the arrays.
As we find an "END" we will associate it with the "START" using the job pid as a key, 
display the job time and unset those records from the arrays.
At the end of the loop all remaining orphaned logs which don't have both "START" and "END" in the log, will remain in the arrays.
We will show some info about them next to the required ones.

## Function to convert HH:MM:SS to seconds
This will create a number which represents the total seconds: HH * 3600 + MM * 60 + SS

## Function to display a message
Because we will display similar output format we will use one function for this.

## Function to display pid duration
We are using this function to calculate the total job duration.
It expects arguments:
- PID , mandatory

## Function to display orphan logs
Check remaining logs which were not in order inside the log file or don't have both "START" and "END" in the log file.