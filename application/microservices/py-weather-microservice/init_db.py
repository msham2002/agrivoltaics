import sqlite3

connection = sqlite3.connect('database.db')


with open('schema.sql') as f:
    connection.executescript(f.read())

cur = connection.cursor()

cur.execute("INSERT INTO weather_updates (date_time, phen, sig) VALUES (?, ?)",
            ('First update', 'snow', 'watch')
            )

cur.execute("INSERT INTO weather_updates (date_time, phen, sig) VALUES (?, ?)",
            ('Second update', 'rain', 'bad')
            )

connection.commit()
connection.close()