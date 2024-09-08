# Zen-Zone
Description:
This project is an interactive audio-visual experiencen designed for waiting rooms, where users can manipulate music and lighting in real time using provided smartphones. 
# The experience involves:
SuperCollider for generating interactive music.
TouchOSC for allowing users to control various parameters of the music from their smartphones.
Python for analyzing the music and detecting its mood, utilizing a machine learning model we trained.
Yeelight, a smart bulb, which changes color based on the detected mood of the music in real time.
# How It Works
The user interacts with TouchOSC via a smartphone.
SuperCollider receives commands from TouchOSC and generates dynamic music.
Python receives the audio signal from SuperCollider and identifies the mood of the music (using a pre-trained model).
Based on the detected mood, Python sends commands to the Yeelight smart bulb, changing its color to reflect the current mood of the music.
# Requirements
Software
SuperCollider: A platform for interactive sound synthesis.
TouchOSC: A remote control app (available for iOS and Android).
Python 3.x: Used for mood detection and controlling the Yeelight bulb.
Required Python libraries:
numpy
scipy
tensorflow (or another machine learning framework used for mood detection)
pyaudio or sounddevice for audio capture
yeelight for controlling the smart bulb
Yeelight: A smart lightbulb that supports the yeelight Python library.
Hardware
Smartphone with the TouchOSC app installed.
Computer to run SuperCollider and Python.
Yeelight bulb connected to the local network.

# Installation
1. Install SuperCollider
Download and install SuperCollider from the official website: https://supercollider.github.io/.
2. Configure TouchOSC
Download the TouchOSC app on your smartphone.
Set up the layout to send OSC messages to SuperCollider. (You can find the configuration file in the /touchosc_layouts directory in this repository).
3. Install Python and dependencies
Ensure you have Python 3.x installed. Install the required dependencies with:

bash
Copia codice
pip install numpy scipy tensorflow pyaudio yeelight

6. Connect the Yeelight bulb
Ensure that your Yeelight bulb is connected to the same Wi-Fi network as your computer. Enable "LAN Control" via the official Yeelight app. Python will control the bulb based on the detected music mood.

Running the Project
1. Start SuperCollider
Run the SuperCollider script to generate the music. You can find the script in the /supercollider_scripts directory.

2. Start the mood recognition process in Python
Run the Python script that analyzes the audio and controls the bulb:

3. Interact with TouchOSC
Now, you can interact with TouchOSC from your smartphone, modifying the music parameters. Python will update the color of the Yeelight bulb in real time based on the detected mood.


# VIDEO DEMO

