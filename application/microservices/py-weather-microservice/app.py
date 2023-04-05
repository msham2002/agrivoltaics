from flask import Flask, request, jsonify, render_template
import requests
import pymongo
from datetime import datetime

client = pymongo.MongoClient('localhost', 27017)
db = client.db
users = db.users
notifications = db.notifications


app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    # Fetch user
    userEmail = request.args.get("email")
    user = users.find_one({"email":userEmail})

    # If user doesn't exist, create it
    if (user == None):
        user = {
            "email": userEmail,
            "last_read": datetime.now()
        }
        users.insert_one(user)

    lat = "36.269035"
    long = "-103.649067"
    response = requests.get(f"https://api.weather.gov/points/{lat},{long}")
    if response.status_code == 200:
        print("Pull successful")
        json_data = response.json()
        alert_api = json_data["properties"]["forecastGridData"]
        hazard_call = requests.get(alert_api)
        if hazard_call.status_code == 200:
            print("Pull successful")
            hazard_data = hazard_call.json()
            hazard_key = hazard_data["properties"]["hazards"]
            phenomenon = {
                "BZ":"Blizzard",
                "WS" : "Winter Storm",
                "WW" : "Winter Weather",
                "SN" : "Snow",
                "HS" : "Heavy Snow",
                "LE" : "Lake Effect Snow",
                "LB" : "Lake Effect and Blowing Snow",
                "BS" : "Blowing/Drifting Snow",
                "SB" : "Snow and Blowing Snow",
                "IP" : "Sleet",
                "HP" : "Heavy Sleet",
                "ZR" : "Freezing Rain",
                "IS" : "Ice Storm",
                "FZ" : "Freeze",
                "ZF" : "Freezing Fog",
                "FR" : "Frost",
                "WC" : "Wind Chill",
                "EC" : "Exctreme Cold",
                "WI" : "Wind",
                "HW" : "High Wind",
                "LW" : "Lake Wind",
                "FG" : "Dense Fog",
                "SM" : "Dense Smoke",
                "HT" : "Heat",
                "EH" : "Excessive Heat",
                "DU" : "Blowing Dust",
                "DS" : "Dust Storm",
                "FL" : "Flood",
                "FF" : "Flash Flood",
                "SV" : "Severe Thunderstorm",
                "TO" : "Tornado",
                "FW" : "Fire Weather",
                "RH" : "Radiological Hazard",
                "VO" : "Volcano",
                "AF" : "Volcanic Ashfall",
                "AS" : "Air Stagnation",
                "AV" :  "Avalanche",
                "TS" :  "Tsunami",
                "MA" : "Marine",
                "SC" : "Small Craft",
                "GL" : "Gale",
                "SR" : "Storm",
                "HF" : "Hurricane Force Wind",
                "TR" : "Tropical Storm",
                "HU" : "Hurricane",
                "TY" : "Typhoon",
                "TI" : "Inland Tropical Storm Wind",
                "HI" : "Inland Hurricane Wind",
                "LS" : "Lakeshore Flood",
                "CF" : "Coastal Flood",
                "UP" : "Ice Accretion",
                "LO" : "Low Water",
                "SU" : "High Surf"
            }
            
            significance  = {
                "W" : "Warning",
                "A" : "Watch",
                "S" : "Statement",
                "Y" : "Advisory"   
            }
            weather_response = []
            hazard_vals = hazard_key["values"]
           
            for instantTime in hazard_vals:
                for val in instantTime["value"]:
                    # dictionary with weather stuff
                    weather_dict = {}

                    weather_dict["time"] = instantTime["validTime"]
                                                   
                    weather_dict["phenomenon"] = phenomenon.get(
                        val.get("phenomenon", "Unknown")
                    )
                    weather_dict["significance"] = significance.get(
                        val.get("significance", "Unknown")
                    )

                    notification = {
                        "body": weather_dict,
                        "timestamp" : datetime.now()
                    }

                    try:
                        notifications.insert_one(notification)
                    except pymongo.errors.DuplicateKeyError as error:
                        print(error)

                        
                    weather_response.append(weather_dict)
                    
            return jsonify(weather_response)
        else:
            return "Error: Unable to fetch hazard data"
    else:
        return "Error: Unable to fetch weather data"

if __name__ == '__main__':
    app.run(debug=True)