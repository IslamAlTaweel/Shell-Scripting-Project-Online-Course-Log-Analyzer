if [ ! -f "log.txt" ]; then
    echo "Error: 'log.txt' not found in the current directory."
    echo "Please make sure the log file is named 'log.txt' and is placed in the same directory as this script."
    exit 1
fi
echo "Welcome the Online Course Log Analyzer."
echo -e "Please select a service from the menu displayed below to proceed.\n"


valServ=0 #flag for service number in case user enters invalid input

while [ "$valServ" -ne 1 ] #incase of invalid user input display menu until valid service is chosen
do
    #display user based interface
    echo "Services Provided:"
    echo "1.) Number of Sessions per Course"
    echo "2.) Average Attendance per Course"
    echo "3.) List of Absent Students per Course"
    echo "4.) List of Late Arrivals per Session"
    echo "5.) List of Students Leaving Early"
    echo "6.) Average Attendance Time per Student per Course"
    echo "7.) Average Number of Attendances per Instructor"
    echo "8.) Most Frequently Used Tool"
    
    read servNum #var to take in user input
    
    case "$servNum"
    in
        [1-8]) valServ=$(( valServ + 1 ));; #valid service number,user may proceed
        *) echo -e "\nInvalid service number.\nPlease enter a valid service number listed in the menu to proceed.\n";; #any char except 1-8 is invalid
    esac
done

case "$servNum"
in
    1) echo -e  "\nNumber of Sessions Conducted per Course:"
       cut -d, -f6,9 log.txt | sort -u | cut -d, -f1 | uniq -c | sort -nr
       ;; #course name in field 6,print duplicate counts,then sort in decreasing order
    2) echo -e "\nEnter the CourseID to compute average attendance:"
       read courseID
       
       course_sessions=$(grep ",$courseID," log.txt | cut -d, -f9 | sort -u)
       
       total_attendees=0
       session_count=0

       for sessionID in $course_sessions; do
           current_session_attendees=$(grep ",$courseID," log.txt | grep ",$sessionID," | cut -d, -f2 | sort -u | wc -l)
           
           total_attendees=$((total_attendees + current_session_attendees))
           session_count=$((session_count + 1))
       done

       if [ "$session_count" -gt 0 ]; then
           average_attendance=$((total_attendees / session_count))
           echo "Average attendance for CourseID $courseID: $average_attendance students per session."
       else
           echo "No sessions found for CourseID $courseID."
       fi
       ;;
    3) echo "Enter Course ID to view the list of absent students:"
       read cID #course ID

       regFile=$(find . -name ${cID}.txt) #find the course's registration file
       
            if [ -z "$regFile" ] #in case course registration file couldn't be found
            then
                echo "Couldn't find registration file for $cID!"
                exit 1
            fi
            
       registered=$(cut -d, -f1 "$regFile") #obtain the students registered in the course

       echo "Absent Students in $cID:" #find registered students who never attended a session
       
            for sID in $registered
            do
                count=$(grep -c ",$sID,.*,$cID," log.txt)
                if [ "$count" -lt 1 ] #display as absent if not even one session had been attended by the student
                then
                    grep "^$sID," "$regFile"
                fi 
            done;;

    4) echo -e "\nEnter the CourseID:"
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
           5) echo "Enter Course ID:"
       read cID 

       echo "Enter Session ID for $cID to view list of students who had left early:"
       read sessID #sessionID

       regFile=$(find . -name "${cID}.txt") #find the course's registration file

       if [ -z "$regFile" ]
       then
           echo "Couldn't find registration file for $cID!"
           exit 1
       fi
       
       # students who joined the session
       sessionAttendance=$(grep "$cID.*,$sessID," log.txt | cut -d, -f2 | sort -u) 

       # if a student leaves five minutes or more before the end of class consider it early
       earlyLeaveThresholdMinutes=5 

       startTime=$(grep "$cID.*,$sessID," log.txt | cut -d, -f7 | cut -d' ' -f2 | head -1)
       sessLen=$(grep "$cID.*,$sessID," log.txt | cut -d, -f8 | head -1)
       
       if [ -z "$sessLen" ]
       then
           echo "Couldn't find session details for Course ID $cID, Session ID $sessID!"
           exit 1
       fi

       startHour=$(echo "$startTime" | cut -d: -f1 | tr -d ' ' | sed 's/^0//')
       startMinute=$(echo "$startTime" | cut -d: -f2 | sed 's/^0//')

       if [ "$sessLen" -ge 60 ]
       then
           sessHours=$(( sessLen / 60 ))
           sessMins=$(( sessLen % 60 ))
       else
           sessHours=0
           sessMins="$sessLen"
       fi
       
       endHour=$(( startHour + sessHours + (startMinute + sessMins)/60 ))
       endMin=$(( (startMinute + sessMins)%60 ))

      
       effectiveEndTotalMinutes=$(( (10#$endHour * 60 + 10#$endMin) - earlyLeaveThresholdMinutes ))
       earlyLeaveHour=$(( effectiveEndTotalMinutes / 60 ))
       earlyLeaveMinute=$(( effectiveEndTotalMinutes % 60 ))

       if [ "$earlyLeaveMinute" -lt 0 ]; then
           earlyLeaveMinute=$(( earlyLeaveMinute + 60 ))
           earlyLeaveHour=$(( earlyLeaveHour - 1 ))
       fi

       formattedEarlyLeaveHour=$(printf "%02d" "$earlyLeaveHour")
       formattedEarlyLeaveMinute=$(printf "%02d" "$earlyLeaveMinute")

       echo "Students who left session $sessID for course $cID early (before ${formattedEarlyLeaveHour}:${formattedEarlyLeaveMinute}):"
       
       for student in $sessionAttendance
       do
          
           student_leave_time=$(grep ",$student,.*,$cID,.*,$sessID," log.txt | cut -d, -f11 | head -1 | sed 's/^ //')
           
           # Skip to the next student if no valid leave time was found for this log entry
           if [ -z "$student_leave_time" ]; then
               continue
           fi

           leftHour=$(echo "$student_leave_time" | cut -d: -f1 | tr -d ' ' | sed 's/^0//')
           leftMinute=$(echo "$student_leave_time" | cut -d: -f2 | sed 's/^0//')

           studentTotalLeaveMinutes=$((10#$leftHour * 60 + 10#$leftMinute))
           
           earlyLeaveTotalMinutes=$((earlyLeaveHour * 60 + earlyLeaveMinute))

           if [ "$studentTotalLeaveMinutes" -le "$earlyLeaveTotalMinutes" ]; then
               grep "^$student," "$regFile" # If so, display the student's registration info
           fi
       done
       ;;

    6)echo -e "\nEnter the CourseID to compute average attendance time per student:"
       read courseID # Get CourseID from the user
       
       students_in_course=$(grep ",$courseID," log.txt | cut -d, -f2,3,4 | sort -u)
       
       echo -e "\nAverage Attendance Time per Student for CourseID $courseID:"
       
       
       echo "$students_in_course" | while IFS=',' read -r studentID firstName lastName; do
           total_attendance_minutes=0 # sum of minutes for each student for this course
           session_count=0            # count of sessions for each student attended in this course.
           
          
           grep ",$studentID,.*,$courseID," log.txt | while read -r line; do
               # Extract student's join and leave times for THIS specific session entry.
               student_begin_time=$(echo "$line" | cut -d, -f10 | sed 's/^ //')
               student_leave_time=$(echo "$line" | cut -d, -f11 | sed 's/^ //')
               
               if [ -n "$student_begin_time" ] && [ -n "$student_leave_time" ]; then
                   # Convert join and leave times into total minutes from midnight.
                   begin_hour=$(echo "$student_begin_time" | cut -d: -f1)
                   begin_minute=$(echo "$student_begin_time" | cut -d: -f2)
                   
                   leave_hour=$(echo "$student_leave_time" | cut -d: -f1)
                   leave_minute=$(echo "$student_leave_time" | cut -d: -f2)
                   
                   begin_total_minutes=$((10#$begin_hour * 60 + 10#$begin_minute))
                   leave_total_minutes=$((10#$leave_hour * 60 + 10#$leave_minute))
                   
                   # calculating how long the student was in this session.
                   session_duration=$((leave_total_minutes - begin_total_minutes))
                   
                   total_attendance_minutes=$((total_attendance_minutes + session_duration))
                   session_count=$((session_count + 1))
               fi
           done
           
           # calculating the average for the sessions for this student.
           if [ "$session_count" -gt 0 ]; then
               average_minutes=$((total_attendance_minutes / session_count))
               echo "  - $firstName $lastName (Student ID: $studentID): $average_minutes minutes per session."
           else
               echo "  - $firstName $lastName (Student ID: $studentID): No attendance records found for this course."
           fi
       done
       ;; 
     7) echo -e  "\nAverage Number of Attendances per Instructor:"
           attendance_per_session=$(cut -d, -f5,9 log.txt | sort -V | uniq -c) #obtain number of students in a session
        instructors=$(cut -d, -f5 log.txt | sort -u)

        for instructor in $instructors
        do 
        sessions_info=$(echo "$attendance_per_session" | grep "$instructor," | sed 's/^ *//' | cut -d' ' -f1)
        total_students=0
        num_of_sessions=0

        for cnt in $sessions_info
        do
        total_students=$(( total_students + cnt ))
        num_of_sessions=$(( num_of_sessions + 1 ))
        done

        if [ "$num_of_sessions" -gt 0 ]
        then
        average_attendance_per_instructor=$(( total_students / num_of_sessions ))
        echo "$instructor : $average_attendance_per_instructor students over $num_of_sessions sessions"
fi
done
;;

    8) echo -e "\nMost Frequently Used Tool:"
       
       # count how many lines start with "Zoom," 
       zoom_count=$(grep -c "^Zoom," log.txt)
       # count how many lines start with "Teams,".
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
