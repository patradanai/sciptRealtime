trap 'deletetempfiles'  EXIT     # calls deletetempfiles function on exit

while :
do

# Dialog utility to display options list

    dialog --clear --backtitle "MENU DRIVEN PROGRAM" --title "MAIN MENU" \
    --menu "Use [UP/DOWN] key to move" 12 60 6 \
    "DATE_TIME" "TO DISPLAY DATE AND TIME" \
    "CALENDAR"  "TO DISPLAY CALENDAR" \
    "DELETE"    "TO DELETE FILES" \
    "USERS"     "TO LIST CURRENTLY LOGGED IN USERS" \
    "DISK"      "TO DISPLAY DISK STATISTICS" \
    "EXIT"      "TO EXIT" 2> menuchoices.$$

    retopt=$?
    choice=`cat menuchoices.$$`

    case $retopt in

           0) case $choice in

                  DATE_TIME)  show_time ;;
                  CALENDAR)   show_cal ;;
                  DELETE)     deletefile ;;
                  USERS)      currentusers ;;
                  DISK)       diskstats ;;
                  EXIT)       clear; exit 0;;

              esac ;;

          *)clear ; exit ;;
    esac

done 