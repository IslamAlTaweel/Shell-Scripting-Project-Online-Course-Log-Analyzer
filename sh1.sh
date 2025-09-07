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
           cut -d, -f6 log.txt | uniq -c | sort -nr ;; #course name in field 6,print duplicate counts,then sort in decreasing order
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
        3) ;;
        4) echo -e "\nEnter the CourseID:"
       read courseID
       echo "Enter the SessionID:"
       read sessionID
       
      
       #i set X to 5 minutes, so lateness is 5 minutes or more.
       late_threshold_minutes=5 
       
       echo -e "\nLate Arrivals for CourseID $courseID, SessionID $sessionID (late by $late_threshold_minutes minutes or more):"
       
       grep ",$courseID," log.txt | grep ",$sessionID," | while IFS=, read -r Tool StudentID FirstName LastName InstructorID CourseID StartDate StartTime Length SessionID StudentBeginDateTime StudentLeaveDateTime; do
           
           scheduled_time=$(echo "$StartTime" | cut -d' ' -f2)
           student_join_time=$(echo "$StudentBeginDateTime" | sed 's/^ //')
           
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
