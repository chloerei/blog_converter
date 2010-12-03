module BlogConverter
  module Importer
    class Blogbus
      def self.import(string)
        doc = Document.new
        xml_doc = Nokogiri::XML(string)
        xml_doc.css('BlogBusCom > Log').each do |log|
          article = Article.new :title        => log.xpath('Title').text,
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
                                  :ip         => comment.xpath('CommentIp')
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
