module BlogConverter
  module Adaptor
    class Blogbus
			Meta = {:dtype => 'BlogData',
							:SchemaVersion => '1.1',
							:Creator => 'BlogConverter'}

			def self.export(doc)
        builder = Nokogiri::XML::Builder.new do |xml|
					xml.BlogBusCom(Meta) do
						doc.articles.each do |article|
							xml.Log do
								xml.Status  1
								xml.Title   article.title
								xml.Writer  article.author
								xml.LogDate article.created_at
								xml.Content article.content
								xml.Excerpt article.summary
								xml.Sort    article.categories.join(' ')
								xml.Tags    article.tags.join(' ')
								xml.Comments do
									article.comments.each do |comment|
										xml.Comment do
											xml.Email       comment.email
											xml.HomePage    comment.url
											xml.NiceName    comment.author
											xml.CommentText comment.content
											xml.CreateTime  comment.created_at
											xml.CommentIp   comment.ip
										end
									end
								end
							end
						end
					end
				end
				builder.to_xml
			end

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
