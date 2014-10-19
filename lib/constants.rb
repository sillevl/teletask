module TeletaskApi
	module 	ConstantName
		def name( val )
    		constants.find{ |name| const_get(name)==val }
  		end
  	end
	module Command
		extend ConstantName
		SET = 7
		GET = 6
		GROUPSET = 9
		LOG = 3
		EVENTREPORT = 0x10
		WRITEDISPLAY = 4
		KEEPALIVE = 0x11
	end

	module Function
		extend ConstantName
		RELAY = 1
		DIMMER = 2
		MOTOR = 6
		LOCALMOOD = 9
		GENERALMOOD = 10
		FLAG = 15
		SENSOR = 20
		AUDIO = 31
		PROCESS = 3
		REGIME = 14
		SERVICE = 53
		MESSAGE = 54
		CONDITION = 60
	end

	module Setting
		extend ConstantName
		ON = 255
		TOGGLE = 103
		OFF = 0

		MOTORUP = 1
		MOTORDOWN = 2
		MOTORSTOP = 3
	end
end