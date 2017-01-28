import requests
import json
from pythonosc import udp_client

def sendwdata(ip, port):
    client = udp_client.SimpleUDPClient(ip, port)
    client.send_message("/tone/freq" , 100)

def fetchwdata(key, loc_state, loc_city):
    """Fetches the weather data from the WundergroundAPI
    Keyword arguments
    key -- The API key for wunderground to fetch the data
    loc_state -- The state for which we are fetching forecast
    loc_city -- The city for which we are fetching forecast
    """
    url = "http://api.wunderground.com/api/{}/geolookup/conditions/q/{}/{}.json".format(key, loc_state, loc_city)
    r = requests.get(url)
    parsed_json = r.json()
    return parsed_json

if __name__ == "__main__":
    with open('key') as input_file:
        for line in input_file:
            key = line.strip()
    ip = "10.250.125.133"
    port = 57120
    loc_state = "PA"
    loc_city  = "Philadelphia"
    parsed_json = fetchwdata(key, loc_state, loc_city)
    print(parsed_json['current_observation']['temp_f'])
