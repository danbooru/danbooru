require './test/test_helper.rb'

class TestImageSize < Test::Unit::TestCase

	def setup
		@files = ['4_1_2.gif', '2-4-7.png', 'tokyo_tower.jpg', 'bmp.bmp', 
		          'ppm.ppm', 'pgm.pgm', 'pbm.pbm', 
		          'cursor.xbm', 'tiff.tiff', 'test.xpm', 
		          'tower_e.gif.psd', 'detect.swf']
		@results = [
		  ['GIF' ,668,481],
		  ['PNG' ,640,532],
		  ['JPEG',320,240],
		  ['BMP' , 50, 50],
		  ['PPM' , 80, 50],
		  ['PGM' , 90, 55],
		  ['PBM' , 85, 55],
		  ['XBM' , 16, 16],
		  ['TIFF', 64, 64],
		  ['XPM' , 32, 32],
		  ['PSD' , 20, 20],
		  ['SWF' ,450,200],
		]
	end

	def teardown
	end

	def test_0_string
#		puts "\n" if $VERBOSE

		@files.each_index do |i|
			file = @files[i]
			result = @results[i]

			open("test/#{file}", "rb") do |fh|
				img_data = fh.read
#				puts "file  =#{file}" if $VERBOSE

				img = ImageSize.new(img_data, result[0])

				assert_equal(result[1], img.get_width)
				assert_equal(result[2], img.get_height)

				img = ImageSize.new(img_data)
				assert_equal(result[0], img.get_type)
				assert_equal(result[1], img.get_width)
				assert_equal(result[2], img.get_height)
			end
		end
	end

	def test_1_io
#		puts "\n" if $VERBOSE

		@files.each_index do |i|
			file = @files[i]
			result = @results[i]

			open("test/#{file}", "rb") do |fh|
#				puts "file  =#{file}" if $VERBOSE

				img = ImageSize.new(fh)
				assert_equal(result[0], img.get_type)
				assert_equal(result[1], img.get_width)
				assert_equal(result[2], img.get_height)
			end
		end
	end
end
