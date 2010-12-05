module BlogConverter
  module Adaptor
    class Wordpress
      RSS_ATTRIBUTES = {:version => '2.0',
                 'xmlns:excerpt' => 'http://purl.org/rss/1.0/modules/content/',
                 'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
                     'xmlns:wfw' => "http://wellformedweb.org/CommentAPI/",
                      'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
                      'xmlns:wp' => "http://wordpress.org/export/1.0/"}

      ArticleStatusExportMapper = {BlogConverter::Article::Status::Publish => 'publish',
                                   BlogConverter::Article::Status::Draft   => 'draft',
                                   BlogConverter::Article::Status::Hide    => 'pending',
                                   BlogConverter::Article::Status::Top     => 'publish'}

      def export(doc)
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.rss(RSS_ATTRIBUTES) do
            doc.articles.each do |article|
              xml.channel do
                xml.item do
                  xml.title              article.title
                  xml.pubDate            article.published_at.rfc2822
                  xml['dc'].creator      {|xml| xml.cdata article.author}
                  xml['content'].encoded {|xml| xml.cdata article.content}
                  xml['excerpt'].encoded {|xml| xml.cdata article.summary}
                  xml['wp'].post_date    article.created_at
                  xml['wp'].post_type    'post'
                  xml['wp'].status       ArticleStatusExportMapper[article.status]

                  article.categories.each do |category|
                    xml.category(:domain => 'category') {|xml| xml.cdata category}
                  end
                  article.tags.each do |tag|
                    xml.category(:domain => 'tag') {|xml| xml.cdata tag}
                  end

                  article.comments.each do |comment|
                    xml['wp'].comment do
                      xml['wp'].comment_author      {|xml| xml.cdata comment.author}
                      xml['wp'].comment_email       comment.email
                      xml['wp'].comment_url         comment.url
                      xml['wp'].comment_content     {|xml| xml.cdata comment.content}
                      xml['wp'].comment_date        comment.created_at
                      xml['wp'].comment_author_IP   comment.ip
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

      ArticleStatusImportMapper = {'pending' => BlogConverter::Article::Status::Hide,
                                   'publish' => BlogConverter::Article::Status::Publish,
                                   'draft'   => BlogConverter::Article::Status::Draft,
                                   'auto-draft'   => BlogConverter::Article::Status::Draft}

      def import(xml)
        doc = Document.new
        xml_doc = Nokogiri::XML(xml)
        xml_doc.css('rss > channel > item').each do |item|
          if item.xpath('wp:post_type').text == 'post'
            article = Article.new :title        => item.xpath('title').text,
                                  :author       => item.xpath('dc:creator').text,
                                  :content      => item.xpath('content:encoded').text,
                                  :summary      => item.xpath('excerpt:encoded').text,
                                  :created_at   => Time.parse(item.xpath('wp:post_date').text),
                                  :published_at => Time.parse(item.xpath('pubDate').text),
                                  :status       => ArticleStatusImportMapper[item.xpath('wp:status').text]

            item.xpath("category[@domain='category']").each do |category|
              article.categories << category.text
            end

            item.xpath("category[@domain='tag']").each do |tag|
              article.tags << tag.text
            end

            item.xpath("wp:comment").each do |comment_item|
              comment = Comment.new :author     => comment_item.xpath('wp:comment_author').text,
                                    :email      => comment_item.xpath('wp:comment_author_email').text,
                                    :url        => comment_item.xpath('wp:comment_author_url').text,
                                    :content    => comment_item.xpath('wp:comment_content').text,
                                    :created_at => Time.parse(comment_item.xpath('wp:comment_date').text),
                                    :ip         => comment_item.xpath('wp:comment_author_IP').text
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
