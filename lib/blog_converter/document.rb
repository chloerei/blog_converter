module BlogConverter
  class Document
    attr_accessor :articles
    def initialize
      @articles = []
    end

    def export(format = :xml)
      case format
      when :xml
        to_xml
      when Type::Wordpress
        Exporter::Wordpress.export self
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
                  end
                end
              end
            end
          end
        end
      end
      builder.to_xml
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
