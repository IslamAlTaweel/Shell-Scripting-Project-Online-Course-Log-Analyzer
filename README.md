# Shell Scripting Project – Online Course Log Analyzer

## Overview
The **Online Course Log Analyzer** is a Bash script designed to process online course session logs stored in `log.txt`. The script provides multiple functionalities to analyze course sessions, attendance, late arrivals, early departures, and instructor statistics. It supports interactive menu-driven usage.

---

## Features
The script provides the following services:

1. **Number of Sessions per Course** – Displays the total number of sessions conducted for each course.  
2. **Average Attendance per Course** – Computes the average number of students attending each session for a specified course.  
3. **List of Absent Students per Course** – Lists students registered for a course but never attended any session.  
4. **List of Late Arrivals per Session** – Shows students who joined a session late (by 5 or more minutes).  
5. **List of Students Leaving Early** – Shows students who left a session early (before the last 5 minutes).  
6. **Average Attendance Time per Student per Course** – Computes average session duration per student for a given course.  
7. **Average Number of Attendances per Instructor** – Shows the average number of students per session for each instructor.  
8. **Most Frequently Used Tool** – Compares usage of Zoom and Teams based on session logs.  
9. **Exit** – Exit the program.

---

## Prerequisites
- Linux or macOS environment.
- Bash shell (`#!/bin/bash`).
- `log.txt` must exist in the same directory as the script.
- Each course has a registration file named `<CourseID>.txt` in the current directory.

---

## Log File Format (`log.txt`)
The script expects `log.txt` to be a CSV file with the following fields (example indices):

| Field | Description |
|-------|-------------|
| 1     | Tool Name (Zoom, Teams, etc.) |
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

## Usage

1. Make sure `log.txt` and all course registration files (`<CourseID>.txt`) are in the same directory as the script.
2. Make the script executable:

```bash
chmod +x course_log_analyzer.sh
