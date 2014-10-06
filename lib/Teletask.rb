require 'socket' 
require 'observer'
require 'timeout'

class Teletask
	include Observable

	module Command
		SET = 7
		GET = 6
		GROUPSET = 9
		LOG = 3
		EVENTREPORT = 0x10
		WRITEDISPLAY = 4
		KEEPALIVE = 0x11
	end

	module Function
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
		ON = 255
		TOGGLE = 103
		OFF = 0

		MOTORUP = 1
		MOTORDOWN = 2
		MOTORSTOP = 3

	end

	class Request
		START = 2
		def initialize command, function = 0, number = 0, setting = nil
			@command = command
			@parameters = Array.new

			case command
			when Teletask::Command::KEEPALIVE
			when Teletask::Command::LOG
				@parameters = Array.new
				@parameters[0] = function
				@parameters[1] = number
			else
				@parameters[0] = 1 		#central number
				@parameters[1] = function
				@parameters[2] = 0 		#byte1
				@parameters[3] = number	#byte2
				@parameters[4] = setting if setting != nil
			end
		end

		def to_s
			#"s,8,7,1,1,0,21,103,143,"
			request = [START, length, @command] + @parameters + [checksum]
			request.pack("C*")
		end

		private
		def checksum
			parametersum = @parameters.empty? ? 0 : @parameters.inject{|sum,x| sum + x }
			return (START + length + @command + parametersum) % 256
		end

		def length
			return @parameters.length + 3
		end
	end

	class Response

		attr_reader :central, :function, :number, :parameters

		def initialize central, function, number, parameters
			@central, @function, @number, @parameters = central, function, number, parameters
		end

		def self.parse data
			begin
				data = data.unpack("C*")
				unless data.first == 10
					startindex = data.index(2) 
					raise "Start byte not found in Response: #{data.inspect}" unless startindex
					length = data[startindex+1]
					calculatedChecksum = data[startindex..startindex+length-1].inject{|sum,x| sum + x } % 256
					checksum = data[startindex+length]
					raise "Checksum mismatch. Expecting #{checksum}, but calculated #{calculatedChecksum}" unless checksum == calculatedChecksum
					raise "Not an response." unless data[startindex+2] == Teletask::Command::EVENTREPORT 
					central = data[startindex+3]
					function = data[startindex+4]
					number = data[startindex+5..startindex+6].pack("c*").unpack("n").first
					parameters =data[startindex+8]
					return Response.new  central, function, number, parameters
				else
					return nil
				end
			rescue Exception => ex
				puts ex
				nil
			end
		end
	end

	@host
	@port
	@socket
	@server

	def initialize(host, port = 55957)
		@host = host
		@port = port
		#add_observer(self)
	end

	def finalize
		close
	end

	def connect
		puts "connecting..."
		@socket = TCPSocket.open @host, @port

		@t = Thread.new{ 
			while (data = @socket.recv(1024))
				response = Response.parse data
				if response
			   		changed
			   		notify_observers(self, response)
			    end
			end
		}
	end

	def close()
		puts "closing connection"
		@socket.close
	end

	def keep_alive
		f = Request.new Command::KEEPALIVE
		@socket.write f.to_s
	end

	def set function, number, setting
		f = Request.new Command::SET, function, number, setting
		@socket.write f.to_s
	end

	def get function, number 
		f = Request.new Command::GET, function, number
		@socket.write f.to_s
	end

	def group_get
		raise NotImplementedError.new
	end

	def log function, setting 
		r = Request.new Command::LOG, function, setting
		@socket.write r.to_s
	end

	def report_event
		raise NotImplementedError.new
	end

	def message
		raise NotImplementedError.new
	end
end

class TeleTaskEvent
	def update object, response
		puts "Update: #{response.inspect}"
	end
end
