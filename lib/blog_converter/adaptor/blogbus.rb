module BlogConverter
  module Adaptor
    class Blogbus
      Meta = {:dtype => 'BlogData',
              :SchemaVersion => '1.1',
              :Creator => 'BlogConverter'}

      ArticleStatusExportMapper = {BlogConverter::Article::Status::Publish => 1,
                                   BlogConverter::Article::Status::Draft   => 0,
                                   BlogConverter::Article::Status::Hide    => 0,
                                   BlogConverter::Article::Status::Top     => 2}

      def export(doc)
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.BlogBusCom(Meta) do
            doc.articles.each do |article|
              xml.Log do
                xml.Status  ArticleStatusExportMapper[article.status]
                xml.Title   article.title
                xml.Writer  article.author
                xml.LogDate article.created_at.strftime("%Y-%m-%d %H:%M:%S")
                xml.Content {|xml| xml.cdata article.content}
                xml.Excerpt {|xml| xml.cdata article.summary}
                xml.Sort    article.categories.join(' ')
                xml.Tags    article.tags.join(' ')
                xml.Comments do
                  article.comments.each do |comment|
                    xml.Comment do
                      xml.Email       comment.email
                      xml.HomePage    comment.url
                      xml.NiceName    comment.author
                      xml.CommentText {|xml| xml.cdata comment.content}
                      xml.CreateTime  {|xml| xml.cdata comment.created_at.strftime("%Y-%m-%d %H:%M:%S")}
                      xml.CommentIp   {|xml| xml.cdata comment.ip}
                    end
                  end
                end
              end
            end
          end
        end
        builder.to_xml
      end

      ArticleStatusImportMapper = {0 => BlogConverter::Article::Status::Hide,
                                   1 => BlogConverter::Article::Status::Publish,
                                   2 => BlogConverter::Article::Status::Top}

      def import(string)
        doc = Document.new
        xml_doc = Nokogiri::XML(string)
        xml_doc.css('BlogBusCom > Log').each do |log|
          article = Article.new :title        => log.xpath('Title').text,
                                :status       => ArticleStatusImportMapper[log.xpath('Status').text.to_i],
                                :content      => log.xpath('Content').text,
                                :summary      => log.xpath('Excerpt').text,
                                :author       => log.xpath('Writer').text,
                                :published_at => Time.parse(log.xpath('LogDate').text),
                                :created_at   => Time.parse(log.xpath('LogDate').text)

          log.css('Comments Comment').each do |comment|
            comment = Comment.new :author     => comment.xpath('NiceName').text,
                                  :email      => comment.xpath('Email').text,
                                  :url        => comment.xpath('HomePage').text,
                                  :content    => comment.xpath('CommentText').text,
                                  :created_at => Time.parse(comment.xpath('CreateTime').text),
                                  :ip         => comment.xpath('CommentIp').text
            article.comments << comment
          end

          article.categories << log.xpath('Sort').text

          log.xpath('Tags').text.split.each do |tag|
            article.tags << tag
          end

          doc.articles << article
        end
        doc
      end
    end
  end
end
