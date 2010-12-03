module BlogConverter
  class Document
    attr_accessor :articles
    def initialize
      @articles = []
    end

    module Type
      Wordpress = 'wordpress'
    end

    def self.parse(string)
      case check_type(string)
      when Type::Wordpress
        Importer::Wordpress.import string
      else
        nil
      end
    end

    private

    def self.check_type(string)
      if is_wordpress?(string)
        Type::Wordpress
      else
        nil
      end
    end

    def self.is_wordpress?(string)
      xml_doc = Nokogiri::XML(string)
      gen = xml_doc.css('rss > channel > generator').first
      gen and gen.text =~ /http:\/\/wordpress.org*/
    end
  end
end
