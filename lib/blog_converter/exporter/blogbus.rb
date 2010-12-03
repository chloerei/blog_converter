module BlogConverter
	module Exporter
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
