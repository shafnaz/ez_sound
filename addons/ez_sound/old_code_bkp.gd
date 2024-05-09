extends Node



#func draw_peak_visualization_wav(data: PackedByteArray, width: int, height: int, format) -> Image:
	#var img = Image.new()
	#img = img.create(width, height, false, Image.FORMAT_RGBA8)
#
	#var step = max(data.size() / width, 1)
	#var height_factor = height / 256.0  # Default for 8-bit audio
#
	#for i in range(width):
		#var idx = int(i * step)
		#if idx >= data.size():
			#break
#
		#var amplitude = 0
		#if format == AudioStreamWAV.FORMAT_8_BITS:
			## 8-bit audio, data[idx] unsigned, convert to signed
			#amplitude = int(data[idx]) - 128
		#elif format == AudioStreamWAV.FORMAT_16_BITS:
			## 16-bit audio
			#if idx + 1 < data.size():
				#amplitude = int(data[idx] + data[idx+1] * 256)
				#amplitude = amplitude if amplitude < 32768 else amplitude - 65536  # Convert to signed
				#height_factor = height / 65536.0  # Adjust height factor for 16-bit
		#else:
			## Handle other formats
			#amplitude = int(data[idx]) - 128
#
		#amplitude = int(amplitude * height_factor) + int(height / 2)
		#amplitude = clamp(amplitude, 0, height - 1)
#
		## Draw vertical line from middle to amplitude and mirror it
		#for y in range(int(height / 2)):
			#if y <= abs(int(height / 2) - amplitude):
				#img.set_pixel(i, int(height / 2) + y, Color(1, 1, 1, 1))  # Draw upward from the middle
				#img.set_pixel(i, int(height / 2) - y, Color(1, 1, 1, 1))  # Draw downward from the middle
#
	#return img
#
#
#
#func draw_peak_visualization_mp3(data: PackedByteArray, width: int, height: int) -> Image:
	#var img = Image.new()
	#img = img.create(width, height, false, Image.FORMAT_RGBA8)
#
	#var step = max(data.size() / width, 1)
	#var height_factor = height / 65536.0  # Approximation for 16-bit audio
#
	#for i in range(width):
		#var idx = int(i * step)
		#if idx + 1 >= data.size():
			#break
#
		## Process 16-bit samples (assuming little endian byte order)
		#var sample = int(data[idx] + data[idx+1] * 256)
		#sample = sample if sample < 32768 else sample - 65536  # Convert to signed
		#
		#var amplitude = int(sample * height_factor) + height / 2
		#amplitude = clamp(amplitude, 0, height - 1)
#
		## Draw vertical line from middle to amplitude and mirror it
		#for y in range(int(height / 2)):
			#if y <= abs(int(height / 2) - amplitude):
				#img.set_pixel(i, height / 2 + y, Color(1, 1, 1, 1))  # Draw upward from the middle
				#img.set_pixel(i, height / 2 - y, Color(1, 1, 1, 1))  # Draw downward from the middle
#
	#return img
