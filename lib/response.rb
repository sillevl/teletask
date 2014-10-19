require_relative './converter'

module TeletaskApi

	class Response

		attr_reader :central, :function, :number, :parameters

		def initialize central, function, number, parameters
			@central, @function, @number, @parameters = central, function, number, parameters
		end

		def self.parse data
			begin
				data = data.unpack("C*")
				#unless data.first == 10
					startindex = data.index(2) 
					raise "Start byte not found in Response: #{data.inspect}" unless startindex
					length = data[startindex+1]
					calculatedChecksum = data[startindex..startindex+length-1].inject{|sum,x| sum + x } % 256
					checksum = data[startindex+length]
					raise "Checksum mismatch. Expecting #{checksum}, but calculated #{calculatedChecksum}" unless checksum == calculatedChecksum
					raise "Not an response." unless data[startindex+2] == Command::EVENTREPORT 
					central = data[startindex+3]
					function = data[startindex+4]
					number = data[startindex+5..startindex+6].pack("c*").unpack("n").first
					case function
					when Function::SENSOR
						parameters =data[startindex+8..startindex+9]
					else
						parameters =data[startindex+8]
					end
					return Response.new  central, function, number, parameters
				#end
			rescue Exception => ex
				puts ex
				nil
			end
			return nil
		end

		def to_hash
			hash = Hash.new
			hash[:function] = function
			hash[:function_name] = Function.name function
			hash[:number] = number
			hash[:parameters] = parameters
			case function
			when Function::SENSOR
				hash[:temperature] = Converter.short_to_temperature parameters
			when Function::RELAY
				hash[:state] = parameters
				hash[:state_name] = Setting.name parameters
			end
			hash
		end
	end

end