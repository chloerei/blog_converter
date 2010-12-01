module BlogConverter
  class Exporter
    class Wordpress
      RSS_ATTRIBUTES = {:version => '2.0',
                 'xmlns:excerpt' => 'http://purl.org/rss/1.0/modules/content/',
                 'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
                     'xmlns:wfw' => "http://wellformedweb.org/CommentAPI/",
                      'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
                      'xmlns:wp' => "http://wordpress.org/export/1.0/"}
      def self.export(doc)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.rss(RSS_ATTRIBUTES) do
            doc.articles.each do |article|
              xml.channel do
                xml.item do
                  xml.title article.title
                  xml.pubDate article.published_at.rfc2822
                  xml['dc'].creator article.author
                  xml['content'].encoded article.content
                  xml['wp'].post_date article.created_at
                  xml['wp'].post_type 'post'
                  xml['wp'].status 'publish'

                  article.categories.each do |category|
                    xml.category category, :domain => 'category'
                  end
                  article.tags.each do |tag|
                    xml.category tag, :domain => 'tag'
                  end

                  article.comments.each do |comment|
                    xml['wp'].comment do
                      xml['wp'].comment_author   comment.author
                      xml['wp'].comment_email    comment.email
                      xml['wp'].comment_url      comment.url
                      xml['wp'].comment_content  comment.content
                      xml['wp'].comment_date     comment.created_at
                      xml['wp'].comment_approved 1
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
