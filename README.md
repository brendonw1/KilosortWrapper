# KilosortWrapper
Allows you to load Kilosort from a .xml and a .dat file compatible with Neurosuite

## Installation
Download and add the KilosortWrapper directory to your matlab path.

## Settings
Most settings are defined in the KilosortConfiguration.m file. Some general settings are defined in the KilosortWrapper file, including: 

* Path to SSD
* Process in subdirectory

Supply a config version input, to use another config file (configuration files should be stored in the ConfigurationFiles folder).
 
## Features
Skip channels: To skip dead channels, select the skip function in Neuroscope or NDManager
Define probe layouts: The wrapper now supports probes with staggered, poly 3 and poly 5 probe layouts...
Allows you to save the output from Kilosort to a sub directory.

## Outputs
The Kilosort wrapper allows you to save the output in Neurosuite compatible files or for Phy. 

### Phy
Saved a channel groups file with information about which shanks the channels are asigned to.
