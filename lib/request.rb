module TeletaskApi
	class Request
		START = 2
		def initialize command, function = 0, number = 0, setting = nil
			@command = command
			@parameters = Array.new

			case command
			when Command::KEEPALIVE
			when Command::LOG
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
end