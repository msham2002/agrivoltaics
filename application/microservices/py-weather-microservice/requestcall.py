import requests
import json

#lat = "39.260375"
#long = "-84.624175"

lat = "36.269035"
long = "-103.649067"

#36.269035, -103.649067

response = requests.get(f"https://api.weather.gov/points/{lat},{long}")

if (response != None):
    print("Pull successful")
else:
    print("Issue with pull")
    
json_data = response.json()

alert_api = json_data["properties"]["forecastGridData"]

print("Printing the key")

print(alert_api)

hazard_call = requests.get(alert_api)

if(hazard_call != None):
    print("Pull successful")
else:
    print("Issue with pull")
    
hazard_data = hazard_call.json()

hazard_key = hazard_data["properties"]["hazards"]

print("printing hazards")

print(hazard_key)

#need to call for the past 12 hours 
#array of dictionaries
#we want to give them phenomen array that has the time and the siginificance
#ideal structure to send
#lifetime : 12 hours
#only care about past 12 hours
[
    {
            "id": "340983409",
            "time": "2023-03-30T17:00:00+00:00/PT9H",
            "phenomenom": "Fire weather",
            "significance": "Watch"
    },
    {
            
            "id": "8594080980",
            "time": "2023-03-40T17:00:00+00:00/PT9H",
            "phenomenom": "Dense Smoke",
            "significance": "Advisory"
    }
]

hazard_vals = hazard_key["values"]

for instantTime in hazard_vals:
    print(instantTime["validTime"])
    for val in instantTime["value"]:
            print(val["phenomenon"])
            print(val["significance"])
            