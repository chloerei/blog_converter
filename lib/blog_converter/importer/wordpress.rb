module BlogConverter
  module Importer
    class Wordpress
      def self.import(xml)
        doc = Document.new
        xml_doc = Nokogiri::XML(xml)
        xml_doc.css('rss > channel > item').each do |item|
          if item.xpath('wp:post_type').text == 'post'
            article = Article.new(:title        => item.xpath('title').text,
                                  :author       => item.xpath('dc:creator').text,
                                  :content      => item.xpath('content:encoded').text,
                                  :summary      => item.xpath('excerpt:encoded').text,
                                  :created_at   => Time.parse(item.xpath('wp:post_date').text),
                                  :published_at => Time.parse(item.xpath('pubDate').text) )

            item.xpath("category[@domain='category']").each do |category|
              article.categories << category.text
            end

            item.xpath("category[@domain='tag']").each do |tag|
              article.tags << tag.text
            end

            item.xpath("wp:comment").each do |comment_item|
              comment = Comment.new(:author     => comment_item.xpath('wp:comment_author').text,
                                    :email      => comment_item.xpath('wp:comment_author_email').text,
                                    :url        => comment_item.xpath('wp:comment_author_url').text,
                                    :content    => comment_item.xpath('wp:comment_content').text,
                                    :created_at => Time.parse(comment_item.xpath('wp:comment_date').text) )
              article.comments << comment
            end

            doc.articles << article
          end
        end
        doc
      end
    end
  end
end
