# AmbientWeather
Author(s): Karishma Changlani, Peter Gagliardi

Ambient music that reacts to the current weather

## Installation

### Dependencies
* Python 3.4+ 
* Wunderground API key
* pip packages:
    * requests, 
    * python-osc, 

### Setup
* Make a file called key.txt which has your winderground API key as it 
  is on the first line. (sample file inlcuded and sample_key) 
* Open SuperCollider and open `ambient_weather.scd` and run all the code blocks. 
  This initializes the synthesizer and prepares the server to receive OSC messages
* run main.py.

## About

AmbientWeather is a collection of SuperCollider synthesizers that are inspired
by the weather. Some are natural sounds like rain or crickets chirping. Others
are synth pads that play patterns of music that remind us of different temperature ranges.

### How it works
![Flowchart](docs/Flowchart.png)

To play music, the python script fetches weather data from [wunderground.com](https://www.wunderground.com). 
It then extracts temperature, precipitation, weather condition, etc from the JSON data. These numbers are converted
to normalized numbers in the range of 0.0 to 1.0 which will eventually control SuperCollider synth settings. 
Normalized values were chosen to allow maximum flexibility and reusability in the SuperCollider code.

The Python script then sends OSC messages to supercollider with the normalized values. The SuperCollider code takes
the temperature and other values and adjusts synth settings (such as which music pattern to play or how heavy the rain is)

This process is repeated at least once a minute to continually react to the weather.

## Synths

### Noise Synths

These synthesizers simulate natural noise. They are selected based on the weather condition

| Synth    | Description       | Weather Condition(s)    | Controlled By | Inspiration | 
|----------|-------------------|-------------------------|---------------|-------------|
| Rain     | Rain sounds       | Rain                    | Temperature controls the amount of rain droplet sound, Precipitation controls the amount of pink noise rain | Modified from [This snippet](http://sccode.org/1-e) |
| Ocean    | Ocean sound       | Clear                   | Temperature controls how much crackling noise is in the wave. | Modified from [This snippet](http://sccode.org/1-1n) |
| Crickets | Crickets Chirping | Cloudy/Overcast/Default | Temperature controls the pitch of crickets chirping, much like [in real life](https://books.google.com/books?id=Jqco0ttVn0gC&lpg=PA970&ots=jVb2ir2UK1&dq=%22The%20Cricket%20as%20a%20Thermometer%22&pg=PA970#v=onepage&q=%22The%20Cricket%20as%20a%20Thermometer%22&f=false) | Modified from [This snippet](http://sccode.org/1-4QB) |

### Pattern Synths

These synthesizers are designed to sound pretty with long release times.

| Synth | Description             | Inspiration |
|-------|-------------------------|-------------|
| Bell  | Drawn-out bell sound    | Modeled after the `PAD Long Bell` from [Syntorial](http://www.syntorial.com/) |
| Pad   | Drawn out PWM pad sound | Modeled after the `PAD PWM` from Syntorial |

Synth patterns are controlled by the temperature range (Cold, Warm and Hot). They each have a set of notes associated with them.
Notes are randomly selected from the set. Additionally, each temperature range can have a different synth and note length

| Temperature Range | Notes           | Instrument | Note Length   | Description        |
|-------------------|-----------------|------------|---------------|--------------------|
| Cold              | C5, D#5, G5, C6 | Pad        | Half Notes    | Slow and dark      |
| Warm              | C5, E5, G5, C6  | Bell       | Quarter Notes | Brisk and cheerful |
| Hot               | C6, E6, G6      | Bell       | Eighth Notes  | Fast and bright    |

## Future Development

These are some features to add in the future:

* Right now, we select only one city at a time. Allow the user to toggle between
  multiple cities interactively
* Add more synths and musical patterns. It would be nice to have several layers of patterns
  playing at once
