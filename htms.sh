#!/bin/bash

# =====================================
# COLORS (UI)
# =====================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# =====================================
# FILES
# =====================================
PATIENT_FILE="patients.txt"
DOCTOR_FILE="doctors.txt"
APPOINT_FILE="appointments.txt"
HISTORY_FILE="history.txt"
INVENTORY_FILE="inventory.txt"
BILL_FILE="bills.txt"
SCHEDULE_FILE="doctor_schedule.txt"

touch $PATIENT_FILE $DOCTOR_FILE $APPOINT_FILE $HISTORY_FILE $INVENTORY_FILE $BILL_FILE $SCHEDULE_FILE

# =====================================
# LOADING & WELCOME
# =====================================
loading() {
    echo -ne "${YELLOW}Loading"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.3
    done
    echo -e "${NC}"
    clear
}

header(){
    echo -e "${CYAN}================================${NC}"
    echo -e "${GREEN} HOSPITAL MANAGEMENT SYSTEM ${NC}"
    echo -e "${CYAN}================================${NC}"
}
welcome() {
    clear
    msg="WELCOME TO HOSPITAL MANAGEMENT SYSTEM"
    for ((i=0; i<${#msg}; i++)); do
        echo -ne "${CYAN}${msg:$i:1}${NC}"
        sleep 0.03
    done
    echo
    sleep 0.5
    clear
}

welcome

# =====================================
# PATIENT MANAGEMENT
# =====================================
add_patient() {
    pid=$(<pid.txt)
    pid=$(($pid + 1))
    read -p "Name: " name
    read -p "Age: " age
    read -p "Gender: " gender
    read -p "Disease: " disease
    echo "$pid|$name|$age|$gender|$disease" >> $PATIENT_FILE
    echo "$pid" > "pid.txt"
    echo -e "${GREEN}Patient added successfully!${NC}"
    sleep 1.0
    clear
}

view_patients() {
    echo -e "${CYAN}--- All Patient information:  ---${NC}"
    #echo "All Patient information: "
    cat $PATIENT_FILE
    echo
    echo
    read -p "Press Enter to return Patient Menu: " todo
}

search_patient() {
    read -p "Patient ID: " pid
    echo -e "${CYAN}--- Patient Information:   ---${NC}"
    grep "$pid" $PATIENT_FILE || echo -e "${RED}Not found!${NC}"
    echo
    echo
    read -p "Press Enter to return Patient Menu: " todo
}

patient_menu() {
    while true; do
    	header
        echo -e "${BLUE}--- Patient Menu ---${NC}"
        echo "1. Add"
        echo "2. View"
        echo "3. Search"
        echo "4. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) add_patient ;;
            2) view_patients ;;
            3) search_patient ;;
            4) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# DOCTOR MANAGEMENT
# =====================================
add_doctor() {
    did=$(<did.txt)
    did=$(($did + 1))
    read -p "Name: " name
    read -p "Specialty: " sp
    echo "$did|$name|$sp" >> $DOCTOR_FILE
    echo "$did" > "did.txt"
    echo -e "${GREEN}Doctor added successfully!${NC}"
    sleep 1.0
}

view_doctors() {
    echo -e "${CYAN}--- All Doctors Information: ---${NC}"
    cat $DOCTOR_FILE
    read -p "Press Enter to return to Doctors Menu: " todo
}

doctor_menu() {
    while true; do
    	header
        echo -e "${BLUE}--- Doctor Menu ---${NC}"
        echo "1. Add"
        echo "2. View"
        echo "3. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) add_doctor ;;
            2) view_doctors ;;
            3) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# DOCTOR SCHEDULE
# =====================================
add_schedule() {
    echo "All Doctors Information: "
    cat $DOCTOR_FILE
    echo
    read -p "Enter Doctor ID: " did
    read -p "Day: " day
    read -p "Available Time(Example: 02:00pm-05:30pm): " time
    echo "$did|$day|$time" >> $SCHEDULE_FILE
    echo -e "${GREEN}Schedule added!${NC}"
    sleep 1.0
}

view_schedule() {
    echo "All Doctors Information: "
    cat $DOCTOR_FILE
    echo
    read -p "Doctor ID: " did
    read -p "Day: " day
    res=$(grep "^$did|$day|" $SCHEDULE_FILE)
    if [ -z "$res" ]; then
        echo -e "${RED}Doctor not available.${NC}"
    else
        echo -e "${CYAN}Available Time:${NC} $(echo $res | cut -d'|' -f3)"
    fi
    
    read -p "Press Enter to return to Doctor Schedule Menu: " todo
}

schedule_menu() {
    while true; do
    	header
        echo -e "${BLUE}--- Doctor Schedule ---${NC}"
        echo "1. Add Schedule"
        echo "2. View Schedule"
        echo "3. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) add_schedule ;;
            2) view_schedule ;;
            3) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# APPOINTMENTS
# =====================================
add_appointment() {
    aid=$(<appid.txt)
    aid=$(($aid + 1))
    echo "All Patients Information: "
    cat $PATIENT_FILE
    read -p "Enter Patient ID: " pid
    
    echo "All Doctors Information: "
    cat $DOCTOR_FILE
    read -p "Enter Doctor ID: " did
    
    echo "Doctors All Schedules: "
    
    res=$(grep "$did|" $SCHEDULE_FILE)
    if [ -z "res" ]; then
    	echo -e "${RED}No Schedule Available for this doctor!${NC}"
    	
    else
    	echo
    	read -p "Choose Schedule Day: " day
    
    	schedule_day=$(grep "$did|$day|" $SCHEDULE_FILE) #Global Regular Expression Print(grep)
    	time=$(echo "$schedule_day" | cut -d'|' -f3)
    
    	echo "$aid|$pid|$did|$day|$time" >> $APPOINT_FILE
    	echo "$aid" > "appid.txt"
    	echo -e "${GREEN}Appointment added!${NC}"
    	sleep 1.0
    fi
}

view_appointments() {
    cat $APPOINT_FILE
    read -p "Press Enter to return to  Appointment Menu: " todo
}

appointment_menu() {
    while true; do
    	header
        echo -e "${BLUE}--- Appointment Menu ---${NC}"
        echo "1. Add"
        echo "2. View"
        echo "3. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) add_appointment ;;
            2) view_appointments ;;
            3) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# MEDICAL HISTORY
# =====================================
add_history() {
    read -p "Patient ID: " pid
    read -p "Date: " date
    read -p "Diagnosis: " diag
    read -p "Treatment: " treat
    echo "$pid|$date|$diag|$treat" >> $HISTORY_FILE
    echo -e "${GREEN}History added!${NC}"
}

view_history() {
    read -p "Patient ID: " pid
    grep "$pid" $HISTORY_FILE || echo -e "${RED}No history found.${NC}"
    read -p "Press Enter to return to Medical History Menu: " todo
}

history_menu() {
    while true; do
    header
        echo -e "${BLUE}--- Medical History ---${NC}"
        echo "1. Add"
        echo "2. View"
        echo "3. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) add_history ;;
            2) view_history ;;
            3) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# INVENTORY
# =====================================
add_medicine() {
    read -p "Medicine ID: " mid
    read -p "Name: " name
    read -p "Quantity: " qty
    echo "$mid|$name|$qty" >> $INVENTORY_FILE
    echo -e "${GREEN}Medicine added!${NC}"
}

view_inventory() {
    echo "Current Inventory: "
    cat $INVENTORY_FILE
    read -p "Press Enter to return to Inventory Menu: " todo
}

inventory_menu() {
    while true; do
    	header
        echo -e "${BLUE}--- Inventory ---${NC}"
        echo "1. Add Medicine"
        echo "2. View Inventory"
        echo "3. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) add_medicine ;;
            2) view_inventory ;;
            3) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# BILLING
# =====================================
create_bill() {
    read -p "Bill ID: " bid
    read -p "Patient ID: " pid
    read -p "Doctor Fee: " fee
    read -p "Medicine Cost: " med
    read -p "Other Charges: " other
    total=$((fee + med + other))
    echo "$bid|$pid|$total" >> $BILL_FILE
    echo -e "${GREEN}Bill Created. Total = $total${NC}"
}

view_bills() {
    echo "All medical bills: "
    cat $BILL_FILE
    read -p "Press Enter to return to Bills Menu: " todo
}

billing_menu() {
    while true; do
    	header
        echo -e "${BLUE}--- Billing ---${NC}"
        echo "1. Create Bill"
        echo "2. View Bills"
        echo "3. Back"
        read -p "Enter your choice: " ch
        case $ch in
            1) create_bill ;;
            2) view_bills ;;
            3) clear
            	break ;;
        esac
        clear
    done
}

# =====================================
# MAIN MENU
# =====================================
while true; do
    header
    echo "1. Patient Management"
    echo "2. Doctor Management"
    echo "3. Doctor Schedule"
    echo "4. Appointment Management"
    echo "5. Medical History"
    echo "6. Pharmaceutical Inventory"
    echo "7. Billing System"
    echo "8. Exit"
    read -p "Enter your choice: " choice
    loading
    case $choice in
        1) patient_menu ;;
        2) doctor_menu ;;
        3) schedule_menu ;;
        4) appointment_menu ;;
        5) history_menu ;;
        6) inventory_menu ;;
        7) billing_menu ;;
        8) exit ;;
    esac
done
