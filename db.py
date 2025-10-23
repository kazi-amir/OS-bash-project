import mysql.connector

mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  password="rootadmin",
  database="osProject"
)

mycursor = mydb.cursor()

sql = "INSERT INTO users VALUES (%s, %s)"
val = ("2", "kazi", "kazi@mail.com")
mycursor.execute(sql, val)

mydb.commit()

print(mycursor.rowcount, "record inserted.")