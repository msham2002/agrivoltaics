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

#print(hazard_key)

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
    "Y" : "Advisoty"   
}

#array of dictionaries
weather_response = []


hazard_vals = hazard_key["values"]

#populate with weather stuff with each loop

#print(hazard_vals)

for instantTime in hazard_vals:
    
    #dictionary with weather stuff
    weather_dict = {}
    
    #print(instantTime["validTime"])
    weather_dict["time"] = instantTime["validTime"]
    
    for val in instantTime["value"]:
            
        #print(val["phenomenon"])
        weather_dict["phenomenon"] = phenomenon[val["phenomenon"]]
            
        #print(val["significance"])
        weather_dict["significance"] = significance[val["significance"]]
          
        weather_response.append(weather_dict)
          
print(weather_response)