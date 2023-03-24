import requests
import json

response = requests.get("https://api.weather.gov/points/39.260375,-84.624175")

print(response)

print("Pull successful")

print(response.json())

print("pull over")

encoded_weatherpull = json.dumps(response.json())
decoded_weatherpull = json.loads(encoded_weatherpull)


for key in encoded_weatherpull:
    if(encoded_weatherpull[key] == 'forecastGridData'):
        print(key)