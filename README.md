# [TF2] VoiceHead

## Description
**VoiceHead** is a SourceMod plugin for Team Fortress 2 that dynamically changes players' head sizes as they speak.

## Features
- **Dynamic Head Scaling**: Heads grow and shrink with the player's voice.
- **Customizable Effects**: Adjust the frequency, amplitude, and base scale of the head wobble through server convars.
- **Player Control**: Players can toggle the head enlargement effect on or off via the cookie menu.

## Installation
1. **Download the Plugin**: Grab the [latest release](https://github.com/roxrosykid/VoiceHead).
2. **Install the Plugin**: Place the `.smx` file in your `tf/addons/sourcemod/plugins/` directory.
3. **Configure the Plugin**: Adjust the convars in the `cfg/sourcemod/head_scale_wobble.cfg` file to customize the effect.

## Usage
- **Enable/Disable dynamic head scaling**: Players can toggle the head enlargement effect by accessing the cookie menu (`!settings` in chat).
- **ConVars**:
  - `sm_headscale_frequency`: Controls how fast the head scales. Default: `25.0`.
  - `sm_headscale_amplitude`: Controls the range of head scaling. Default: `0.4`.
  - `sm_headscale_base_scale`: Base scale applied when a player starts speaking. Default: `1.5`.

## Commands
- **!settings**: Access the cookie menu to enable or disable the head enlargement effect.