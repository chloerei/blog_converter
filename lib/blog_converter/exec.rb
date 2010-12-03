require 'optparse'

module BlogConverter
	class Exec
		def initialize(argv)
			@options = {}
			@opts = OptionParser.new
			@opts.banner = <<END
Usage: blog_converter [options] INPUT [OUTPUT]

Description:
	Uses blog converter to convert blog archive to each other, like blogbus, wordpress, etc.

Options:
END
			@opts.on("-f FORMAT", :REQUIRED, "Output format, options: blogbus, wordpress, xml") {|val| @options[:output_format] = val.to_sym}
			@opts.on_tail("-?", "-h", "--help", "Show this message") do
				puts @opts
				exit
			end
			@opts.parse! argv
			@options[:input] = argv.shift
			@options[:output] = argv.shift
		end

		def run
			string = File.open(@options[:input]).read
			result = BlogConverter.parse(string).export(@options[:output_format])
			if @options[:output]
				File.open @options[:output], 'w' do |f|
					f.write result
				end
			else
				puts result
			end

		end
	end
end
