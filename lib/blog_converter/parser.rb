require 'time'
require 'blog_converter/importer/wordpress'

module BlogConverter
  class Parser
    attr_reader :doc

    def self.parse(xml)
      self.new(xml).doc
    end

    module Type
      Wordpress = 'wordpress'
    end

    private

    def initialize(xml)
      @original = xml
      @xml_doc = Nokogiri::XML(xml)
      @doc = Document.new

      check_type
      parse
    end

    def check_type
      gen = @xml_doc.css('rss > channel > generator').first
      if gen and gen.text =~ /http:\/\/wordpress.org*/
        @type = Type::Wordpress
        return
      end
    end

    def parse
      case @type
      when Type::Wordpress
        @doc = Importer::Wordpress.import @original 
      else
      end
    end
  end
end
