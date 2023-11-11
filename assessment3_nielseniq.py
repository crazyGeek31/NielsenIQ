# You are tasked with writing a Python script that retrieves IP location information from the API provided at https://ipapi.co/json. 
# The API returns a JSON file containing various details, including the IP address and location information. 
# Your script should handle potential errors gracefully.

import sys
import json
from requests import get


def get_location():
    # Fetching the Location details using GET request to the API and retrieving as JSON response
    loc = get(f'https://ipapi.co/json/')

    data = loc.json()
    if loc.status_code == 200:
        # Parsing the JSON response to extract the IP address and location information
        # data = loc.json()
        loc_details = {
          "ip": data.get("ip"),
          "city": data.get("city"),
          "region": data.get("region"),
          "country": data.get("country_name"),
          "timezone": data.get("timezone")
        }
        # Display the IP address and location information on the console.
        return loc_details
    # Implementing error handling to account for potential issues
    elif loc.status_code == 403:
        print("Invalid authorization credentials")
        print(data.get("message"))
    elif loc.status_code == 404:
        print("Page not found error")
        print(data.get("message"))
    elif loc.status_code == 429:
        print("Request was rate limited")
        print(data.get("message"))
    else:
       print("Error Occured due to ",data.get("reason"))
       print(data.get("message"))
    

def main(argv=None):
    print(get_location())

main()