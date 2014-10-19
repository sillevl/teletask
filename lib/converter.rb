module TeletaskApi
	class Converter
		def self.short_to_temperature short
			(short.pack("cc").unpack("s>").first / 10.0 - 273).round(1)
		end

		def self.temperature_to_short temperature_to_short
			raise NotImplementedError
		end

		def self.byte_to_humidity byte
			raise NotImplementedError
		end

		def self.humidity_to_byte humidity
			raise NotImplementedError
		end

		def self.byte_to_lux byte
			raise NotImplementedError
		end

		def self.lux_to_byte lux
			raise NotImplementedError
		end
	end
end