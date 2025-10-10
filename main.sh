#!/bin/bash

# Define the database file
DB_FILE="students.db"

# Ensure the database file exists
touch "$DB_FILE"

# --- Helper Functions for UI ---
# Use tput for colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# Function to display a centered header
show_header() {
    clear
    echo "${BLUE}=========================================${RESET}"
    echo "${BLUE}    Student Information Management System    ${RESET}"
    echo "${BLUE}=========================================${RESET}"
    echo
}

# --- Core Logic Functions ---

## 1. Add a New Student
add_student() {
    show_header
    echo "--- Add New Student Record ---"
    
    # Get Student ID and validate
    while true; do
        read -p "Enter Student ID: " student_id
        # Check if ID already exists
        if grep -q "^$student_id:" "$DB_FILE"; then
            echo "${RED}Error: Student ID '$student_id' already exists. Please use a unique ID.${RESET}"
        else
            break
        fi
    done

    read -p "Enter Full Name: " full_name
    read -p "Enter Email Address: " email
    read -p "Enter Major: " major

    # Append the new record to the database file
    echo "$student_id:$full_name:$email:$major" >> "$DB_FILE"
    
    echo "${GREEN}Success: Student record for '$full_name' has been added.${RESET}"
    sleep 2
}

## 2. View All Students
view_students() {
    show_header
    echo "--- All Student Records ---"
    
    # Check if the database is empty
    if [ ! -s "$DB_FILE" ]; then
        echo "${RED}No student records found.${RESET}"
    else
        # Print a formatted table header
        printf "%-10s | %-25s | %-30s | %-20s\n" "ID" "Full Name" "Email" "Major"
        echo "---------------------------------------------------------------------------------------"
        # Read the file line by line and print formatted output
        while IFS=: read -r id name email major; do
            printf "%-10s | %-25s | %-30s | %-20s\n" "$id" "$name" "$email" "$major"
        done < "$DB_FILE"
    fi
    
    echo
    read -p "Press [Enter] to return to the main menu..."
}

## 3. Search for a Student
search_student() {
    show_header
    echo "--- Search for a Student ---"
    read -p "Enter Student ID or Name to search: " search_term
    
    # Use grep to find matching records (case-insensitive)
    local results
    results=$(grep -i "$search_term" "$DB_FILE")

    if [ -z "$results" ]; then
        echo "${RED}No records found matching '$search_term'.${RESET}"
    else
        echo "--- Search Results ---"
        printf "%-10s | %-25s | %-30s | %-20s\n" "ID" "Full Name" "Email" "Major"
        echo "---------------------------------------------------------------------------------------"
        echo "$results" | while IFS=: read -r id name email major; do
            printf "%-10s | %-25s | %-30s | %-20s\n" "$id" "$name" "$email" "$major"
        done
    fi
    
    echo
    read -p "Press [Enter] to return to the main menu..."
}

## 4. Update a Student Record
update_student() {
    show_header
    echo "--- Update a Student Record ---"
    read -p "Enter the ID of the student to update: " student_id

    # Check if the student exists
    if ! grep -q "^$student_id:" "$DB_FILE"; then
        echo "${RED}Error: Student with ID '$student_id' not found.${RESET}"
        sleep 2
        return
    fi

    # Get the current record
    local record
    record=$(grep "^$student_id:" "$DB_FILE")
    local old_name=$(echo "$record" | cut -d: -f2)
    local old_email=$(echo "$record" | cut -d: -f3)
    local old_major=$(echo "$record" | cut -d: -f4)

    echo "Updating record for ID: $student_id"
    echo "Current Name: $old_name"
    read -p "Enter new Full Name (or press Enter to keep current): " new_name
    [ -z "$new_name" ] && new_name=$old_name

    echo "Current Email: $old_email"
    read -p "Enter new Email (or press Enter to keep current): " new_email
    [ -z "$new_email" ] && new_email=$old_email

    echo "Current Major: $old_major"
    read -p "Enter new Major (or press Enter to keep current): " new_major
    [ -z "$new_major" ] && new_major=$old_major

    # Create the new record string
    local new_record="$student_id:$new_name:$new_email:$new_major"

    # Use sed to replace the old line with the new one
    sed -i "s/^$student_id:.*/$new_record/" "$DB_FILE"
    
    echo "${GREEN}Success: Record for ID '$student_id' has been updated.${RESET}"
    sleep 2
}

## 5. Delete a Student
delete_student() {
    show_header
    echo "--- Delete a Student Record ---"
    read -p "Enter the ID of the student to delete: " student_id

    # Find the record to be deleted
    local record
    record=$(grep "^$student_id:" "$DB_FILE")

    if [ -z "$record" ]; then
        echo "${RED}Error: Student with ID '$student_id' not found.${RESET}"
        sleep 2
        return
    fi
    
    echo "Found record to delete:"
    echo "$record"
    echo
    read -p "Are you sure you want to permanently delete this record? (y/n): " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        # Use grep -v to filter out the line to be deleted
        grep -v "^$student_id:" "$DB_FILE" > "${DB_FILE}.tmp"
        mv "${DB_FILE}.tmp" "$DB_FILE"
        echo "${GREEN}Success: Record for ID '$student_id' has been deleted.${RESET}"
    else
        echo "Deletion cancelled."
    fi
    sleep 2
}


# --- Main Menu Loop ---
while true; do
    show_header
    echo "Please choose an option:"
    echo "  1. Add New Student"
    echo "  2. View All Students"
    echo "  3. Search for a Student"
    echo "  4. Update Student Record"
    echo "  5. Delete Student Record"
    echo "  6. Exit"
    echo
    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1) add_student ;;
        2) view_students ;;
        3) search_student ;;
        4) update_student ;;
        5) delete_student ;;
        6) echo "Thank you for using the system. Goodbye!"; exit 0 ;;
        *) echo "${RED}Invalid option. Please try again.${RESET}"; sleep 2 ;;
    esac
done