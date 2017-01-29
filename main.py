#!/usr/bin/env python3
import requests
import json
from pythonosc import udp_client
import argparse
import time

conditions_mapping = { 'Partly Cloudy': 3, 
        'Rain' : 1, 
        'Cloudy' : 3, 
        'Overcast': 3, 
        'Clear': 2}

def sendWData(ip, port, inputs):
    """Sends signal to the synth collider to change its audio output 
    Function Parameters: 
    ip -- The ip address of the supercolliderd is hosted
    port -- The port where there supercollider is attached 
    inputs -- The input data to send to synth collider
    """
    print("Sending inputs to synth")
    client = udp_client.SimpleUDPClient(ip, port)
    client.send_message("/weather/conditions", inputs['conditions'])
    client.send_message("/weather/temperature" , inputs['temperature'])
    client.send_message("/weather/precipitation" , inputs['precipitation'])
    client.send_message("/weather/warmth", inputs['warmth'])

def fetchWData(key, loc_state, loc_city):
    """Fetches the weather data from the WundergroundAPI
    
    Function Parameters:
    key -- The API key for wunderground to fetch the data
    loc_state -- The state for which we are fetching forecast
    loc_city -- The city for which we are fetching forecast
    """
    url = "http://api.wunderground.com/api/{}/geolookup/conditions/q/{}/{}.json".format(key, loc_state, loc_city)
    print(url)
    r = requests.get(url)
    parsed_json = r.json()
    return parsed_json

def normalizeValue(old_max, old_min, val): 
    """Takes a value and it's range and normalizes it to a range between 0 to 1
   
    Function Parameters: 
    old_max -- the max range of the current raw value 
    old_min -- the min range of the current raw value
    val -- the value to normalize (double)
    
    Returns the value normalized (double) 

    """
    if val >= old_max: 
        return 1
    if val <= old_min: 
        return 0 
    answer = val - old_min
    answer = answer/(old_max-old_min)
    return answer

    
def calculateWarmth(normalized_temp):
    """
    Put the normalized temperature value into one of three buckets:
    Cold (0), Warm (1), Hot (2)
    
    Function Parameters
    normalized_temp -- Temperature value from 0.0 to 1.0
    """
    if normalized_temp < 1.0 / 3.0:
        return 0
    elif normalized_temp < 2.0 / 3.0:
        return 1
    else:
        return 2
    
def normalizeWData(current_observations): 
    """Takes the current observation and reduces it to a range between 0 to 1 using teh normalzeValue function
    
    Function Parameters
    current_observations -- the weather data to normalize
    """
    return_data = {}
    try: 
        return_data['conditions'] = conditions_mapping[current_observations['weather']]
    except: 
        return_data['conditions'] = 3

    #Values set on winter conditions, change for your convenience
    (temp_max, temp_min) = (80, 10)
    (prec_max, prec_min) = (100, 0)
    return_data['temperature'] = normalizeValue(temp_max, temp_min, float(current_observations['temp_f']) )
    return_data['warmth'] = calculateWarmth(return_data['temperature'])
    return_data['precipitation'] = normalizeValue(prec_max, prec_min, float(current_observations['precip_1hr_metric']))
    return return_data

if __name__ == "__main__":
    with open('key') as input_file:
        for line in input_file:
            key = line.strip()
    parser = argparse.ArgumentParser(description='Command line arguments')
    parser.add_argument('port', type=int, help='the port for the synth server')
    parser.add_argument('ip', type=str, help='ip address of the synth server')
    parser.add_argument('state', type=str, help='location state of the weather report')
    parser.add_argument('city', type=str, help='location city of the weather report')

    args = parser.parse_args()

    ip = args.ip
    port = args.port
    loc_state = args.state
    loc_city  = args.city
    
    while True: 
        parsed_json = fetchWData(key, loc_state, loc_city)
        sendWData(ip, port, normalizeWData(parsed_json['current_observation']))
        time.sleep(60)
