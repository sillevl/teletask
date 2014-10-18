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

teletask = Teletask.new("192.168.1.5")
teletask.connect()

teletask.get Teletask::Function::RELAY, 21
```
