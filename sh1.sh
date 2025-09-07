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
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        6) ;;
        7) ;;
        8) ;;
esac
