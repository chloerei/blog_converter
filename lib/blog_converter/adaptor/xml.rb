module BlogConverter
  module Adaptor
    class Xml
      def self.export(doc)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document do 
            doc.articles.each do |article|
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
    end
  end
end
