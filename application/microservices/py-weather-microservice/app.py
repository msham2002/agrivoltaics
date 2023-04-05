from flask import Flask, request, jsonify, render_template
import requests
import pymongo
from bson.json_util import dumps
from datetime import datetime

client = pymongo.MongoClient('localhost', 27017)
db = client.db
users = db.users
notifications = db.notifications

app = Flask(__name__)

def fetch_user(email):
    # Fetch user
    user = users.find_one({"email":email})

    # If user doesn't exist, create it
    if (user == None):
        user = {
            "email": email,
            "last_read": datetime.now()
        }
        users.insert_one(user)

    return user

@app.route('/getNotifications', methods=['GET'])
def get_notifications():
    # Fetch user
    userEmail = request.args.get("email")
    user = fetch_user(userEmail)

    # Fetch notifications posted after user's last_read attribute
    recent_notifications = notifications.find({"timestamp": {"$gt": user["last_read"]}})
    
    # Return response
    response = {
        "notifications": eval(dumps(list(recent_notifications)))
    }
    return response

@app.route('/readNotifications', methods=['POST'])
def read_notifications():
    # Fetch user
    userEmail = request.args.get("email")
    user = fetch_user(userEmail)

    # Update user's last_read attribute
    users.update_one({"email": user["email"]}, {"$set": {"last_read": datetime.now()}})


if __name__ == '__main__':
    app.run(debug=True)