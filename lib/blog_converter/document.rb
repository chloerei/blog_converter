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
      doc = nil
      case check_type(string)
      when Type::Wordpress
        doc = Importer::Wordpress.import string
      else
        puts "Unknow Documnet Type"
      end
      doc
    end

    private

    def self.check_type(string)
      type = nil
      xml_doc = Nokogiri::XML(string)
      gen = xml_doc.css('rss > channel > generator').first
      if gen and gen.text =~ /http:\/\/wordpress.org*/
        type = Type::Wordpress
      end
      type
    end
  end
end
