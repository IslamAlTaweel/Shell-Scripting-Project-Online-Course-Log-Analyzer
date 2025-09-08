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
   3) echo "Enter Course ID:"
      read cID #course ID

      regFile=$(find . -name ${cID}.txt) #find the course's registration file
            if [ -z "$regFile" ]
            then
                echo "Couldn't find registration file for $cID!"
                exit 1
            fi
       registered=$(cut -d, -f1 "$regFile") #obtain the students registered in the course
       attended=$(grep "$cID" log.txt | cut -d, -f2) #obtain the students who attended any session in the course

        echo "Absent Students in $cID:" #find registerd students who never attended a session
            for sID in $registered
            do
                count=$(grep -c ",$sID.*,$cID," log.txt)
                if [ "$count" -lt 1 ]
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
    5) ;;
    6) ;;
    7) ;;
    8) ;;
esac
