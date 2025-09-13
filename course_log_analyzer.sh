#!/bin/bash
if [ ! -f "log.txt" ]; then # diplay error msg in case log file isnt found in directory
	echo "Error: 'log.txt' not found in the current directory."
	echo "Please make sure the log file is named 'log.txt' and is placed in the same directory as this script."
	exit 1
fi
echo -e "\nWelcome the Online Course Log Analyzer."

while :; do # display the service menu till the user chooses to exit
	echo -e "\nPlease select a service from the menu displayed below to proceed.\n"

	#incase of invalid user input display menu until valid service is chosen
	#display user based interface
	echo "Services Provided:"
	echo "1. Number of Sessions per Course"
	echo "2. Average Attendance per Course"
	echo "3. List of Absent Students per Course"
	echo "4. List of Late Arrivals per Session"
	echo "5. List of Students Leaving Early"
	echo "6. Average Attendance Time per Student per Course"
	echo "7. Average Number of Attendances per Instructor"
	echo "8. Most Frequently Used Tool"
	echo "9. Exit"
	read servNum #var to take in user input for service number

	case "$servNum" in # used to validate user input
	[1-8]) ;;          #valid user input
	9)
		echo "Exiting Program.....GoodBye!"
		break # close program if user chooses exit, breaks out of while true loop
		;;
	*) echo -e "\nInvalid service number.\n" ;; #any char except 1-8 is invalid user input
	esac

	case "$servNum" in
	1)
		echo -e "\nNumber of Sessions Conducted per Course:"
		cut -d, -f6,9 log.txt | sort -u | cut -d, -f1 | uniq -c | sort -nr
		;; #course name in field 6,print duplicate counts,then sort in decsending order
	2)
		echo -e "\nEnter the CourseID to compute average attendance:"
		read courseID
		#obtain unique session IDs for the course
		course_sessions=$(grep ",$courseID," log.txt | cut -d, -f9 | sort -u)

		total_attendees=0
		session_count=0

		for sessionID in $course_sessions; do #loop over each session ID
			# obtain the number of unique students in the session
			current_session_attendees=$(grep ",$courseID," log.txt | grep ",$sessionID," | cut -d, -f2 | sort -u | wc -l)

			total_attendees=$((total_attendees + current_session_attendees))
			session_count=$((session_count + 1))
		done

		if [ "$session_count" -gt 0 ]; then # compute and display average attendance per session
			average_attendance=$((total_attendees / session_count))
			echo "Average attendance for CourseID $courseID: $average_attendance students per session."
		else
			echo "No sessions found for CourseID $courseID."
		fi
		;;
	3)
		echo "Enter Course ID to view the list of absent students:"
		read cID #course ID

		regFile=$(find . -name ${cID}.txt) #find the course's registration file

		if [ -z "$regFile" ]; then #in case course registration file couldn't be found display error msg
			echo "Couldn't find registration file for $cID!"
			continue #exit service if no registration file found
		fi

		registered=$(cut -d, -f1 "$regFile") #obtain the students registered in the course

		echo "Absent Students in $cID:" #find registered students who never attended a session

		for sID in $registered; do # obtain student log from file, if none then display absent
			count=$(grep -c ",$sID,.*,$cID," log.txt)
			if [ "$count" -lt 1 ]; then #display as absent if not even one session had been attended by the student
				grep "^$sID," "$regFile"
			fi
		done
		;;

	4)
		echo -e "\nEnter the CourseID:"
		read courseID
		echo "Enter the SessionID:"
		read sessionID

		lateness_period=5 # X minutes or more after scheduled start is late. X is set to 5.

		echo -e "\nLate Arrivals for CourseID $courseID, SessionID $sessionID (late by $lateness_period minutes or more):"

		# read each filtered line into a single variable, then use cut to extract fields
		grep ",$courseID," log.txt | grep ",$sessionID," | while read -r line; do

			# extracting fields using cut on the line variable
			FirstName=$(echo "$line" | cut -d, -f3)
			LastName=$(echo "$line" | cut -d, -f4)
			StudentID=$(echo "$line" | cut -d, -f2)
			StartTime_full=$(echo "$line" | cut -d, -f7)
			StudentBeginDateTime_full=$(echo "$line" | cut -d, -f10)

			scheduled_time=$(echo "$StartTime_full" | cut -d' ' -f2)
			student_join_time=$(echo "$StudentBeginDateTime_full" | sed 's/^ //')

			scheduled_hour=$(echo "$scheduled_time" | cut -d: -f1)
			scheduled_minute=$(echo "$scheduled_time" | cut -d: -f2)

			join_hour=$(echo "$student_join_time" | cut -d: -f1)
			join_minute=$(echo "$student_join_time" | cut -d: -f2)

			scheduled_total_minutes=$((10#$scheduled_hour * 60 + 10#$scheduled_minute))
			join_total_minutes=$((10#$join_hour * 60 + 10#$join_minute))

			time_difference_minutes=$((join_total_minutes - scheduled_total_minutes))

			if [ "$time_difference_minutes" -ge "$lateness_period" ]; then
				echo "  - $FirstName $LastName (Student ID: $StudentID) joined at $student_join_time (Scheduled: $scheduled_time)"
			fi
		done
		;;
	5)
		echo "Enter Course ID:"
		read cID

		echo "Enter Session ID for $cID to view list of students who had left early:"
		read sessID #sessionID

		regFile=$(find . -name "${cID}.txt") #find the course's registration file

		if [ -z "$regFile" ]; then # display error msg in case registration file isn't found
			echo "Couldn't find registration file for $cID!"
			continue
		fi

		# obtain unique students who joined the session
		sessionAttendance=$(grep "$cID.*,$sessID," log.txt | cut -d, -f2 | sort -u)

		# if a student leaves five minutes or more before the end of class consider it early
		earlyLeaveThresholdMinutes=5

		#obtain the session time and length from any one line logged for that session
		startTime=$(grep "$cID.*,$sessID," log.txt | cut -d, -f7 | cut -d' ' -f2 | head -1)
		sessLen=$(grep "$cID.*,$sessID," log.txt | cut -d, -f8 | head -1)

		if [ -z "$sessLen" ]; then # exit service in case session length couldn't be found
			echo "Couldn't find session details for Course ID $cID, Session ID $sessID!"
			continue
		fi

		startHour=$(echo "$startTime" | cut -d: -f1 | tr -d ' ' | sed 's/^0//')
		startMinute=$(echo "$startTime" | cut -d: -f2 | sed 's/^0//')
		# convert session length to hours and minutes
		if [ "$sessLen" -ge 60 ]; then
			sessHours=$((sessLen / 60))
			sessMins=$((sessLen % 60))
		else
			sessHours=0
			sessMins="$sessLen"
		fi
		# compute session end time
		endHour=$((startHour + sessHours + (startMinute + sessMins) / 60))
		endMin=$(((startMinute + sessMins) % 60))
		#compute minimum time considered to be an early leave
		effectiveEndTotalMinutes=$(((10#$endHour * 60 + 10#$endMin) - earlyLeaveThresholdMinutes))
		earlyLeaveHour=$((effectiveEndTotalMinutes / 60))
		earlyLeaveMinute=$((effectiveEndTotalMinutes % 60))

		formattedEarlyLeaveHour=$(printf "%02d" "$earlyLeaveHour")
		formattedEarlyLeaveMinute=$(printf "%02d" "$earlyLeaveMinute")

		echo "Students who left session $sessID for course $cID early (before ${formattedEarlyLeaveHour}:${formattedEarlyLeaveMinute}):"

		for student in $sessionAttendance; do

			student_leave_time=$(grep ",$student,.*,$cID,.*,$sessID," log.txt | cut -d, -f11 | head -1 | sed 's/^ //')

			# Skip to the next student if no valid leave time was found for this log entry
			if [ -z "$student_leave_time" ]; then
				continue # skip current iteration in case of corrupted data
			fi

			leftHour=$(echo "$student_leave_time" | cut -d: -f1 | tr -d ' ' | sed 's/^0//')
			leftMinute=$(echo "$student_leave_time" | cut -d: -f2 | sed 's/^0//')

			studentTotalLeaveMinutes=$((10#$leftHour * 60 + 10#$leftMinute))

			earlyLeaveTotalMinutes=$((earlyLeaveHour * 60 + earlyLeaveMinute))

			if [ "$studentTotalLeaveMinutes" -le "$earlyLeaveTotalMinutes" ]; then
				grep "^$student," "$regFile" # If left early, display the student's registration info
			fi
		done
		;;

	6)
		echo -e "\nEnter the CourseID to compute average attendance time per student:"
		read courseID # get CourseID from the user

		students_in_course=$(grep ",$courseID," log.txt | cut -d, -f2,3,4 | sort -u)

		echo -e "\nAverage Attendance Time per Student for CourseID $courseID:"

		while IFS=',' read -r studentID firstName lastName; do
			total_attendance_minutes=0 # sum of minutes for each student for this course
			session_count=0            # count of sessions for each student attended in this course.

			# extract student's join and leave times for the specific session entry.
			while IFS=',' read -r tool sid fname lname instructor course session startTime duration student_begin_time student_leave_time; do
				student_begin_time=$(echo "$student_begin_time" | sed 's/^ *//;s/ *$//')
				student_leave_time=$(echo "$student_leave_time" | sed 's/^ *//;s/ *$//')

				if [ -n "$student_begin_time" ] && [ -n "$student_leave_time" ]; then
					begin_hour=$(echo "$student_begin_time" | cut -d: -f1)
					begin_minute=$(echo "$student_begin_time" | cut -d: -f2)

					leave_hour=$(echo "$student_leave_time" | cut -d: -f1)
					leave_minute=$(echo "$student_leave_time" | cut -d: -f2)

					begin_total_minutes=$((10#$begin_hour * 60 + 10#$begin_minute))
					leave_total_minutes=$((10#$leave_hour * 60 + 10#$leave_minute))

					# calculating how long the student was in this session.
					session_duration=$((leave_total_minutes - begin_total_minutes))

					if [ "$session_duration" -ge 0 ]; then
						total_attendance_minutes=$((total_attendance_minutes + session_duration))
						session_count=$((session_count + 1))
					fi
				fi
			done < <(grep ",$studentID,.*,$courseID," log.txt)

			# calculating the average for the sessions for this student.
			if [ "$session_count" -gt 0 ]; then
				average_minutes=$((total_attendance_minutes / session_count))
				echo "  - $firstName $lastName (Student ID: $studentID): $average_minutes minutes per session."
			else
				echo "  - $firstName $lastName (Student ID: $studentID): No attendance records found for this course."
			fi
		done <<<"$students_in_course"
		;;
	7)
		echo -e "\nAverage Number of Attendances per Instructor:"
		attendance_per_session=$(cut -d, -f5,9 log.txt | sort -V | uniq -c) # obtain number of students per session
		instructors=$(cut -d, -f5 log.txt | sort -u)                        # obtain all the different instructors

		for instructor in $instructors; do
			#obtain the student count per session which is = finding the session count in the log file
			sessions_info=$(echo "$attendance_per_session" | grep "$instructor," | sed 's/^ *//' | cut -d' ' -f1)
			total_students=0  # used to sum total student attendees across all the sessions of an instructor
			num_of_sessions=0 # used to obtain the number of sessions taught by an instructor

			for cnt in $sessions_info; do             # loop through the session count of an instructor
				total_students=$((total_students + cnt)) # add the number of students in this session to the total amount of students
				num_of_sessions=$((num_of_sessions + 1)) # increment the number of sessions
			done
			#avoid division by 0
			if [ "$num_of_sessions" -gt 0 ]; then # compute and display the average attendance per instructor
				average_attendance_per_instructor=$((total_students / num_of_sessions))
				echo "$instructor : $average_attendance_per_instructor students over $num_of_sessions sessions"
			fi
		done
		;;

	8)
		echo -e "\nMost Frequently Used Tool:"

		# count how many lines start with Zoom
		zoom_count=$(grep -c "^Zoom," log.txt)
		# count how many lines start with Teams
		teams_count=$(grep -c "^Teams," log.txt)

		# comparing counts
		if [ "$zoom_count" -gt "$teams_count" ]; then
			echo "Zoom is used more frequently ($zoom_count sessions) than Teams ($teams_count sessions)."
		elif [ "$teams_count" -gt "$zoom_count" ]; then
			echo "Teams is used more frequently ($teams_count sessions) than Zoom ($zoom_count sessions)."
		else
			echo "Zoom and Teams are used equally frequently ($zoom_count sessions each)."
		fi
		;;
	esac

done
