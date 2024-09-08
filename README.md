# Zen-Zone
# Project Overview

ZENZONE uses real-time music generation and emotion-driven lighting to create an immersive environment. Users can control the system using the _TouchOSC_ app on their devices, which sends OSC messages to _SuperCollider_, the sound synthesis engine. In parallel, _Python_ handles real-time analysis of the music and controls lighting based on the emotional tone of the music, classified as either "Valence" or "Energy".

The interaction includes controlling instruments like Synth Pad, Piano, Drums, and Background Ambience, all of which are synthesized and played through _SuperCollider_. _Python_ manages the audio classification and visual feedback using pre-trained models.


# The experience involves:
1. _SuperCollider_ for generating interactive music.
2. _TouchOSC_ for allowing users to control various parameters of the music from their smartphones.
3. _Python_ for analyzing the music and detecting its mood, utilizing a machine learning model we trained.
4. _Yeelight_, a smart bulb, which changes color based on the detected mood of the music in real time.
# How It Works
The user interacts with _TouchOSC_ via a smartphone.
_SuperCollider_ receives commands from _TouchOSC_ and generates dynamic music.
_Python_ receives the audio signal from _SuperCollider_ and identifies the mood of the music (using a pre-trained model).
Based on the detected mood, _Python_ sends commands to the Yeelight smart bulb, changing its color to reflect the current mood of the music.
# Requirements
Software:
- _SuperCollider_: A platform for interactive sound synthesis.
- SC3-PLUGINS (Supercollider)
- _TouchOSC_: A remote control app (available for iOS and Android).
- _Python_ 3.x: Used for mood detection and controlling the Yeelight bulb.
  
Required Python libraries:
- numpy
- scipy
- tensorflow (or another machine learning framework used for mood detection)
- pyaudio or sounddevice for audio capture
- yeelight for controlling the smart bulb
-Yeelight: A smart lightbulb that supports the yeelight Python library.

Hardware:
- Smartphone with the TouchOSC app installed.
- Computer to run SuperCollider and Python.
- Yeelight bulb connected to the local network.

# Installation
1. Install SuperCollider from the official website: https://supercollider.github.io/.
3. Download the TouchOSC app on your smartphone.
Set up the layout to send OSC messages to SuperCollider. (You can find the configuration file in the ZENZONE.TOUCHMK1.touchosc in this repository).
4. Install Python and dependencies
Ensure you have Python 3.x installed. Install the required dependencies with:
5. Connect the Yeelight bulb
Ensure that your Yeelight bulb is connected to the same Wi-Fi network as your computer. Enable "LAN Control" via the official Yeelight app. Python will control the bulb based on the detected music mood.

# Running the Project
1. Start SuperCollider
Run the SuperCollider script to generate the music. You can find the script in the /ZenZOne-Supercollider_ZenZone directory.

2. Start the mood recognition process in Python
Run the Python script Main_ZenZone that analyzes the audio and controls the bulb:

3. Open TouchOSC and select the name of your layout.
Now, you can interact with TouchOSC from your smartphone, modifying the music parameters. Python will update the color of the Yeelight bulb in real time based on the detected mood.


# VIDEO DEMO
https://www.youtube.com/watch?v=_SYIxqFthYA&feature=youtu.be
