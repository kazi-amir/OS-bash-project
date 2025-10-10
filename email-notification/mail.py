import smtplib
from email.message import EmailMessage
import os # Recommended for securely handling credentials

# --- CONFIGURATION ---
RECEIVER_EMAIL = "kaziah444@gmail.com"
SENDER_EMAIL = os.environ.get('EMAIL_USER')
SENDER_PASSWORD = os.environ.get('EMAIL_PASS')


# Email details
SUBJECT = "Test Mail From Python"

# Path to the external text file containing the email body
BODY_FILE_PATH = "email_body.txt"

# Server details
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

def send_notification():
    # Read the email body from the external text file
    try:
        with open(BODY_FILE_PATH, 'r', encoding='utf-8') as f:
            email_body = f.read()
    except FileNotFoundError:
        print(f"Error: Body file not found at '{BODY_FILE_PATH}'. Please create the file.")
        return # Stop the function if the file doesn't exist
    except Exception as e:
        print(f"An error occurred while reading the file: {e}")
        return

    # Create the email message object
    msg = EmailMessage()
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECEIVER_EMAIL
    msg.set_content(email_body)

    print("Attempting to send an email...")

    try:
        # Connect to the SMTP server
        # Using a `with` statement ensures the connection is automatically closed
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()  # Upgrade the connection to a secure one
            server.login(SENDER_EMAIL, SENDER_PASSWORD) # Login to the email account
            server.send_message(msg) # Send the email

        print(f"Email sent successfully to {RECEIVER_EMAIL}")

    except smtplib.SMTPAuthenticationError:
        print("Failed to send email: SMTP Authentication Error.")
        print("   Please check your SENDER_EMAIL and SENDER_PASSWORD (ensure it's an App Password).")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":

    print("Email notification script started. Press Ctrl+C to stop.")
    try:
        # while True:
        send_notification()
        # print(f"Waiting for {INTERVAL_SECONDS} seconds before the next email...")
        # time.sleep(INTERVAL_SECONDS)
    except KeyboardInterrupt:
        print("\nScript stopped by user. Shutting down.")