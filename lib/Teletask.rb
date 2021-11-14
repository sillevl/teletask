require 'socket' 
require 'observer'
require 'timeout'

require_relative './constants'
require_relative './request'
require_relative './response'


module TeletaskApi
	class Teletask
		include Observable

		@host
		@port
		@socket
		@server

		def initialize(host, port = 55957)
			@host = host
			@port = port
			add_observer(self)
		end

		def finalize
			close
		end

		def connect
			puts "Connecting to Teletask on #{@host} at port #{@port}..."
			@socket = TCPSocket.open @host, @port
			puts "Connected"
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

		def update object, response
			puts "Update: #{response.to_hash.inspect}"
		end
	end

end
