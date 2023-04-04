from pymongo import MongoClient
import datetime

client = MongoClient('localhost', 27017)
db = client.db

users = db.users
notifications = db.notifications

user = {
    "email": "will@gmail.com",
    "last_read": datetime.datetime.now()
}
users.insert_one(user)

notification = {
    "body": {
        "weather": "bad",
        "time": datetime.datetime.now()
    },
    "timestamp": datetime.datetime.now()
}
notifications.insert_one(notification)