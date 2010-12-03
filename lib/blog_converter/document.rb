module BlogConverter
  class Document
    attr_accessor :articles
    def initialize
      @articles = []
    end

    module Type
      Wordpress = :wordpress
      Blogbus   = :blogbus
    end

    def self.parse(string, importer = nil)
      importer ||= case check_type(string)
                   when Type::Wordpress
                     Importer::Wordpress
                   when Type::Blogbus
                     Importer::Blogbus
                   else
                     return nil
                   end
      importer.import string
    end

    private

    def self.check_type(string)
      xml_doc = Nokogiri::XML(string)
      if gen = xml_doc.css('rss > channel > generator').first and gen.text =~ /http:\/\/wordpress.org*/
        Type::Wordpress
      elsif gen = xml_doc.css('BlogBusCom').first and gen['dtype'] == 'BlogData'
        Type::Blogbus
      else
        nil
      end
    end
  end
end
