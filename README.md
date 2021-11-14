Teletask ruby gem
========

Ruby gem for communicating with Teletask domotics central using the DoIP protocol
At the moment there is support for 
* keep_alive
* set
* get
* log

In next releases support for these features will be added
* group_get
* message

### Installation

`gem install teletask`

### Usage

example

```
require 'teletask'

teletask = TeletaskApi.new("192.168.1.5")
teletask.connect()

#switch on relay #21
teletask.set TeletaskApi::Function::RELAY, 21, 100
# switch off relay #21
teletask.set TeletaskApi::Function::RELAY, 21, 0
```
#get temp of Sensor #1
teletask.get TeletaskApi::Function::SENSOR, 01
