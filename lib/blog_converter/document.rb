module BlogConverter
  class Document
    module Type
      Wordpress = :wordpress
      Blogbus   = :blogbus
    end

    AdaptorMapper = {Type::Wordpress => BlogConverter::Adaptor::Wordpress,
                     Type::Blogbus   => BlogConverter::Adaptor::Blogbus}

    attr_accessor :articles
    def initialize
      @articles = []
    end

    def export(exporter = :xml)
      if exporter.is_a? Symbol
        case exporter
        when :xml
          return to_xml
        else
          exporter = AdaptorMapper[exporter]
        end
      end

      if exporter.respond_to? :export
        exporter.export self
      else
        nil
      end
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.document do 
          self.articles.each do |article|
            xml.article do
              xml.author       article.author
              xml.title        article.title
              xml.content      article.content
              xml.summary      article.summary
              xml.created_at   article.created_at
              xml.published_at article.published_at
              xml.tags do
                article.tags.each do |tag|
                  xml.tag tag
                end
              end
              xml.categories do
                article.categories.each do |category|
                  xml.category category
                end
              end
              xml.comments do
                article.comments.each do |comment|
                  xml.comment do
                    xml.author     comment.author
                    xml.email      comment.email
                    xml.url        comment.url
                    xml.content    comment.content
                    xml.created_at comment.created_at
                    xml.ip         comment.ip
                  end
                end
              end
            end
          end
        end
      end
      builder.to_xml
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
