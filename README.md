# Shell Scripting Project – Online Course Log Analyzer

## Overview
The **Online Course Log Analyzer** is a Bash Shell script that processes session records generated from online teaching platforms and stored in a file named log.txt. A wide range of features is offered for analyzing course activity, including session details, attendance tracking, late arrivals, early departures, and instructor-related statistics. The tool is designed for interactive, menu-driven use, making it easy for the user to explore and interpret online course log data.

---

## Features
The shell script provides the following services:

1. Number of Sessions per Course
      - Displays the total number of sessions conducted for each course
      - Sorts the courses in increasing order of session count

2. Average Attendance per Course
      - Computes the average number of students attending per session for a given course
      - Takes into account all sessions recorded in `log.txt`

3. List of Absent Students per Course
      - Shows students registered in a course who never attended any session
      - Requires a corresponding registration file named (`CourseID.txt`) for the course 

4. List of Late Arrivals per Session
      - Lists students who joined a session later than the allowed threshold (default 5 minutes)
      - Shows scheduled time versus actual join time

5. List of Students Leaving Early
      - Displays students who left a session at least 5 minutes before the end of the session 
      - Requires session start time and length from `log.txt`

6. Average Attendance Time per Student per Course
      - Calculates the average time each student spends in sessions for a specific course
      - Takes all attended sessions into account

7. Average Number of Attendances per Instructor
      - Computes the average number of students per session for each instructor
      - Aggregates data from all sessions in `log.txt`

8. Most Frequently Used Tool
      - Compares the usage of Zoom vs. Teams
      - Shows which tool is used more frequently based on session counts

9. Exit
      - Ends the program.

---

## Prerequisites
- Linux environment
- Bash shell (`#!/bin/bash`)
- `log.txt` must exist in the same directory as the script
- Each course has a corresponding registration file named `CourseID.txt` in the current directory

---

## Log File Format (`log.txt`)
The shell script expects `log.txt` to be structured in a CSV ( comma seperated values ) formatted file consisting of the following fields:

| Field | Description |
|-------|-------------|
| 1     | Tool Name (Zoom or Teams) |
| 2     | Student ID |
| 3     | First Name |
| 4     | Last Name |
| 5     | Instructor Name |
| 6     | Course Name |
| 7     | Session Date & Start Time |
| 8     | Session Length (minutes) |
| 9     | Session ID |
| 10    | Student Join Time |
| 11    | Student Leave Time |

---

## Execution Instructions 

1. Ensure that `log.txt` and all course registration files (`CourseID.txt`) are in the same directory as the script.
2. Make the shell script executable:

```bash
chmod +x course_log_analyzer.sh
```


## Screenshots of the execution from services 1-8
![47979271-0e68-463f-b613-6594ad27b29b](https://github.com/user-attachments/assets/13c60e41-9590-4494-a1cf-c4b2deda1617)
![0cfcf1be-51b9-41f4-a758-bcc8323d2b38](https://github.com/user-attachments/assets/62d88fda-0588-41b7-b4c9-1e1f460bafef)
![5987123e-bb9c-4a62-b46c-6aa12c6edd58](https://github.com/user-attachments/assets/479da35b-6c2e-4c5b-8594-fbcfa43dbb99)
![90e580ba-882d-4b34-bb12-5a3f81ff7282](https://github.com/user-attachments/assets/828e76f9-12c8-4d09-b563-b2cb49c75bf1)
![eb7173c0-426d-4251-b4fe-8e1576e5560a](https://github.com/user-attachments/assets/341e0951-d987-4238-9e75-65c1eb20e79e)
![0e030dc5-97f8-493a-a590-89bca44bc969](https://github.com/user-attachments/assets/c5c9d455-46a4-49d1-be87-58e0ae43bf50)
![5ba7aed3-2529-4959-ad3d-f814525b2207](https://github.com/user-attachments/assets/c15e8c37-ba7a-4df4-95e0-71931b8f30f3)
![f0f4070c-a1d2-4409-b6da-98f901a4a206](https://github.com/user-attachments/assets/0fed54f5-77ad-43ec-96ae-26959022f7f5)

