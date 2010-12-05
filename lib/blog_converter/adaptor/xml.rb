module BlogConverter
  module Adaptor
    class Xml
      def export(doc)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document do 
            doc.articles.each do |article|
              xml.article do
                xml.status       article.status
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

      def import(string)
        xml_doc = Nokogiri::XML(string)
        doc = BlogConverter::Document.new
        xml_doc.css('document > article').each do |article_item|
          article = BlogConverter::Article.new
          %w( title content summary published_at created_at author status ).each do |column|
            text = article_item.xpath(column).text
            unless text.empty?
              if %w( published_at created_at ).include? column
                article.send("#{column}=", Time.parse(text))
              else
                article.send("#{column}=", text)
              end
            end
          end

          article_item.css('categories category').each do |category_item|
            article.categories << category_item.text
          end

          article_item.css('tags tag').each do |tag_item|
            article.categories << tag_item.text
          end

          article_item.css('comments comment').each do |comment_item|
            comment = BlogConverter::Comment.new
            %w( author email url content created_at ip ).each do |column|
              text = comment_item.css(column).text
              unless text.empty?
                if %w( published_at created_at ).include? column
                  comment.send "#{column}=", Time.parse()
                else
                  comment.send "#{column}=", comment_item.css(column).text
                end
              end
            end
            article.comments << comment
          end

          doc.articles << article
        end
        doc
      end
    end
  end
end
