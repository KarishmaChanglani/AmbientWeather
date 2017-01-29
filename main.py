import requests
import json
from pythonosc import udp_client

conditions_mapping = { 'Partly Cloudy': 1, 
        'Rain' : 2, 
        'Cloudy' : 1, 
        'Overcast': 1, }

def sendWData(ip, port, inputs):
    """Sends signal to the synth collider to change its audio output 
    Function Parameters: 
    ip -- The ip address of the supercolliderd is hosted
    port -- The port where there supercollider is attached 
    inputs -- The input data to send to synth collider
    """
    client = udp_client.SimpleUDPClient(ip, port)
    client.send_message("/weather/temperature" , inputs['temperature'])
    client.send_message("/weather/precipitation" , inputs['precipitation'])

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

def normalizeWData(current_observations): 
    """Takes the current observation and reduces it to a range between 0 to 1 using teh normalzeValue function
    
    Function Parameters
    current_observations -- the weather data to normalize
    """
    return_data = {}
    return_data['conditions'] = conditions_mapping[current_observations['weather']]
    #Values set on winter conditions, change for your convenience
    (temp_max, temp_min) = (80, 10)
    (prec_max, prec_min) = (100, 0)
    return_data['temperature'] = normalizeValue(temp_max, temp_min, float(current_observations['temp_f']) )
    return_data['precipitation'] = normalizeValue(prec_max, prec_min, float(current_observations['precip_1hr_metric']))
    return return_data

if __name__ == "__main__":
    with open('key') as input_file:
        for line in input_file:
            key = line.strip()
    ip = "10.250.125.133"
    port = 57120
    loc_state = "PA"
    loc_city  = "Philadelphia"
    parsed_json = fetchWData(key, loc_state, loc_city)
    print("The current temperature(F): {}".format(parsed_json['current_observation']['temp_f']))
    sendWData(ip, port, normalizeWData(parsed_json['current_observation']))
