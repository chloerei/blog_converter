module BlogConverter
  class Parser
    attr_reader :doc
    module Type
      Wordpress = 'wordpress'
    end

    def initialize(xml)
      @xml_doc = Nokogiri::XML(xml)
      @doc = Document.new

      check_type
      parse
    end

    def check_type
      gen = @xml_doc.css('rss > channel > generator').first
      if gen and gen.text =~ /http:\/\/wordpress.org*/
        @doc.type = Type::Wordpress
        return
      end
    end

    def parse
      case @doc.type
      when Type::Wordpress
        parse_as_wordpress
      else
      end
    end

    def parse_as_wordpress
      @xml_doc.css('rss > channel > item').each do |item|
        if item.xpath('wp:post_type').text == 'post'
          @doc.articles << Article.new
        end
      end
    end

    def self.parse(xml)
      self.new(xml).doc
    end
  end
end
