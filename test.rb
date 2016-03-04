class Widget
	def initialize
		class << self
			attr_accessor :key
		end

		self.key = "hello world"
	end
end

x = Widget.new
puts x.key
