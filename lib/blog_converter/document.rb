module BlogConverter
  class Document
    module Type
      Wordpress = :wordpress
      Blogbus   = :blogbus
      Xml       = :xml
    end

    AdaptorMapper = {Type::Wordpress => BlogConverter::Adaptor::Wordpress,
                     Type::Blogbus   => BlogConverter::Adaptor::Blogbus,
                     Type::Xml       => BlogConverter::Adaptor::Xml}

    attr_accessor :articles
    def initialize
      @articles = []
    end

    def export(exporter = :xml)
      if exporter.is_a? Symbol
        exporter = AdaptorMapper[exporter]
      end

      if exporter.respond_to? :export
        exporter.export self
      else
        nil
      end
    end

    def to_xml
      Adaptor::Xml.export self
    end

    def self.parse(string, importer = nil)
      importer ||= check_type(string)

      if importer.is_a? Symbol
        importer = AdaptorMapper[importer]
      end

      if importer.respond_to? :export
        importer.import string 
      else
        nil
      end
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
