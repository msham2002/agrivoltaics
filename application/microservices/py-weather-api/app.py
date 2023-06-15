import os
import flask
import pymongo
from bson.json_util import dumps
from datetime import datetime
import waitress

# Initialize Mongo client, database, and collections
mongo_password = os.environ["MONGO_PASSWORD"]
client = pymongo.MongoClient(f"mongodb+srv://agrivoltaicsgrafana:{mongo_password}@vinovoltaics-cluster.qhgrw48.mongodb.net/?retryWrites=true&w=majority", 27017)
db = client.db
users = db.users
notifications = db.notifications

# Initialize indexes
if "body_index" not in notifications.index_information():
    notifications.create_index("body", name="body_index", unique=True)

if "unique_user_index" not in users.index_information():
    users.create_index([("email", 1), ("last_read", 1)], name="unique_user_index", unique=True)

app = flask.Flask(__name__)

def fetch_user(email):
    # Fetch user
    user = users.find_one({"email":email})

    # If user doesn't exist, create it
    if (user == None):
        user = {
            "email": email,
            "last_read": datetime.utcnow(),
            "settings": {
                "singleGraphToggle": False,
                "timeZone": "America/New_York",
                "returnDataFilter": "max",
                "site1": {
                    "site_checked": True,
                    "nickName": "",
                    "zone1": {
                        "zone_checked": True,
                        "nickName": "",
                        "humidity": True,
                        "temperature": True,
                        "light": True,
                        "rain": True,
                        "frost": True,
                        "soil": True
                }
            }
        }
    }
        users.insert_one(user)

    return user

@app.route('/getNotifications', methods=['GET'])
def get_notifications():
    # Fetch user
    userEmail = flask.request.args.get("email")
    user = fetch_user(userEmail)

    # Fetch notifications posted after user's last_read attribute
    recent_notifications = notifications.find({"timestamp": {"$gt": user["last_read"]}})
    
    # Format response
    responseJson = {
        "notifications": eval(dumps(list(recent_notifications)))
    }
    # Undo default bson encoding
    for notification in responseJson["notifications"]:
        notification.pop("_id")
        notification["timestamp"] = notification["timestamp"]["$date"]

    # Return response
    response = flask.jsonify(responseJson)
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/readNotifications', methods=['POST'])
def read_notifications():
    # Fetch user
    userEmail = flask.request.args.get("email")
    user = fetch_user(userEmail)

    # Update user's last_read attribute
    users.update_one({"email": user["email"]}, {"$set": {"last_read": datetime.utcnow()}})
    response = flask.jsonify()
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

# Run server
waitress.serve(app=app, port=8080, url_scheme='http')