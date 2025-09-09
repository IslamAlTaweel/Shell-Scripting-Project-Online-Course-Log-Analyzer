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
       attended=$(grep "$cID" log.txt | cut -d, -f2) #obtain the students who attended any session in the course

       echo "Absent Students in $cID:" #find registered students who never attended a session
       
            for sID in $registered
            do
                count=$(grep -c ",$sID.*,$cID," log.txt)
                if [ "$count" -lt 1 ] #display as absent if not even one session had been attended by the student
                then
                    grep "^$sID," "$regFile"
                fi 
            done;;

    4) echo -e "\nEnter the CourseID:"
       read courseID
       echo "Enter the SessionID:"
       read sessionID
       
       late_threshold_minutes=5 # Lateness rule: X minutes or more after scheduled start. X is set to 5.
       
       echo -e "\nLate Arrivals for CourseID $courseID, SessionID $sessionID (late by $late_threshold_minutes minutes or more):"
       
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
           
           if [ "$time_difference_minutes" -ge "$late_threshold_minutes" ]; then
               echo "  - $FirstName $LastName (Student ID: $StudentID) joined at $student_join_time (Scheduled: $scheduled_time)"
           fi
       done
       ;;
    5) echo "Enter Course ID:"
       read cID  #course ID

       echo "Enter Session ID for $cID to view list of students who had left early:"
       read sessID #sessionID
       regFile=$(find . -name ${cID}.txt) #find the course's registration file
               if [ -z "$regFile" ]
               then
               echo "Couldn't find registration file for $cID!"
               exit 1
               fi

       sessionAttendance=$(grep "$cID.*,$sessID," log.txt | cut -d, -f2) #students who joined the session
       early_threshold_min=5 #if a student leaves five minutes or more before the end of class consider it early
       startTime=$(grep "$cID.*,$sessID," log.txt | cut -d, -f7 | cut -d' ' -f2 | head -1)
       startHour=$(echo "$startTime" | cut -d: -f1 | tr -d '')
       hourNum1=$(echo "$startHour" | cut -c1)
               if [ "$hourNum1" -eq 0 ]
               then
               startHour=$(echo "$startHour" | cut -c2)
               fi
       startMinute=$(echo "$startTime" | cut -d: -f2)
       minNum1=$(echo "$startMinute" | cut -c1)
               if [ "$minNum1" -eq 0 ]  
               then
               startMinute=$(echo "$startMinute" | cut -c2)
               fi

       sessLen=$(grep "$cID.*,$sessID," log.txt |  cut -d, -f8 | head -1)
               if [ -z "$sessLen" ]
               then
               echo "Couldn't find sesssion"
               exit 1
               fi

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

             if [ "$endMin" -ge "$early_threshold_min" ]
             then
               early_leave_minute=$(( endMin - early_threshold_min ))
               early_leave_hour="$endHour"
             elif [ "$early_threshold_min" -ne 0 ] #in case 0 is the threshold
             then
                minutes=$(( endMin - early_threshold_min ))
                early_leave_minute=$(( minutes + 60 ))
                early_leave_hour=$(( endHour - 1 ))
             else
                early_leave_minute="$endMin"
                early_leave_hour="$endHour"
            fi
        echo "Students who left early:"
        for student in $sessionAttendance
        do
        student_leave_time=$(grep ",$student.*,$cID.*,$sessID," log.txt | cut -d, -f11)
        leftHour=$(echo "$student_leave_time" | cut -d: -f1 | tr -d ' ')
         leftHourNum1=$(echo "$leftHour" | cut -c1)
                if [ "$leftHourNum1" -eq 0 ]
                then
                leftHour=$(echo "$leftHour" | cut -c2)
fi

 leftMinute=$(echo "$student_leave_time" | cut -d: -f2)
 leftMinNum1=$(echo "$leftMinute" | cut -c1)
 
                if [ "$leftMinNum1" -eq 0 ]
                then
                leftMinute=$(echo "$leftMinute" | cut -c2)
fi

        if [ "$leftHour" -lt "$early_leave_hour" ]
        then
        grep "$student," "$regFile"
        elif [ "$leftHour" -eq "$early_leave_hour" ]
        then
                if [ "$leftMinute" -lt "$early_leave_minute" ]
                then
                grep "$student," "$regFile"
fi
fi
done
 ;;
    6) ;;
    7) ;;
    8) ;;
esac
