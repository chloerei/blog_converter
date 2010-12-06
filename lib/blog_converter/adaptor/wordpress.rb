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

      attr_accessor :wpautop

      def initialize(options = {})
        @wpautop = options[:wpautop] || true
      end

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
                                  :content      => wpautop_filter(item.xpath('content:encoded').text),
                                  :excerpt      => wpautop_filter(item.xpath('excerpt:encoded').text),
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
                                    :content    => wpautop_filter(comment_item.xpath('wp:comment_content').text),
                                    :url        => comment_item.xpath('wp:comment_author_url').text,
                                    :created_at => Time.parse(comment_item.xpath('wp:comment_date').text),
                                    :ip         => comment_item.xpath('wp:comment_author_IP').text
              article.comments << comment
            end

            doc.articles << article
          end
        end
        doc
      end

      def wpautop?
        wpautop
      end

      # rewrite function wpautop() in wordpress3.0.2 wp-inlcudes/formatting.php
      def wpautop_filter(string, br = true)
        return string if !wpautop?

        string.strip!
        return if string.empty?

        string << "\n" # just to make things a little easier, pad the end
        string.gsub!(%r|<br />\s*<br />|, "\n\n")
        # Space things out a little
        allblocks = '(?:table|thead|tfoot|caption|col|colgroup|tbody|tr|td|th|div|dl|dd|dt|ul|ol|li|pre|select|option|form|map|area|blockquote|address|math|style|input|p|h[1-6]|hr|fieldset|legend|section|article|aside|hgroup|header|footer|nav|figure|figcaption|details|menu|summary)'
        string.gsub!(Regexp.new('<' + allblocks + '[^>]*>')) {|s| "\n#{s}"}
        string.gsub!(Regexp.new('</' + allblocks + '>')) {|s| "#{s}\n\n"}
        # cross-platform newlines
        string.gsub!("\r\n", "\n")
        string.gsub!("\r", "\n")
        if (string.include? '<object')
          # no pee inside object/embed
          string.gsub!(/\s*<param([^>]*)>\s*/) {|s| "<param#{$1}>"}
          string.gsub!(/\s*<\/embed>\s*/, '</embed>')
        end
        string.gsub!(/\n\n+/, "\n\n") # take care of duplicates
        # make paragraphs, including one at the end
        pees = string.split(/\n\s*\n/)
        string = ''
        pees.each do |pee|
          string << "<p>" + pee.strip + "</p>\n"
        end
        string.gsub!(/<p>\s*<\/p>/, "") # under certain strange conditions it could create a p of entirely whitespace
        string.gsub!(%r!<p>([^<]+)</(div|address|form)>!) {|s| "<p>#{$1}</p></#{$2}>"}
        string.gsub!(Regexp.new('<p>\s*(</?' + allblocks  + '[^>]*)\s*</p>')) {|s| $1} # don't pee all over a tag
        string.gsub!(%r|<p>(<li.+?)</p>|) {|s| $1} # problem with nested lists
        string.gsub!(%r|<p><blockquote([^>]*)>|) {|s| "<blockquote#{$1}><p>"}
        string.gsub!(%r|</blockquote></p>|, "<p><blockquote>")
        string.gsub!(Regexp.new('<p>\s*(</?' + allblocks + '[^>]*>)')) {|s| $1} 
        string.gsub!(Regexp.new('(</?' + allblocks + '[^>]*>)\s*</p>')) {|s| $1}
        if br
          string.gsub!(/<(script|style).*?<\/\\1>/s) {|s| s.gusb "\n", "WPPreserveNewline />" }
          string.gsub!(%r|(?<!<br />)\s*\n|, "<br />\n") # optionally make line breaks
          string.gsub!('<WPPreserveNewline />', "\n")
        end
        string.gsub!(Regexp.new('(</?' + allblocks + '[^>]*>)\s*<br />')) {|s| $1}
        string.gsub!(%r!<br />(\s*</?(?:p|li|div|dl|dd|dt|th|pre|td|ul|ol)[^>]*>)!) {|s| $1}
        if string.include?('<pre')
          # clean_pre
          string.gsub!(%r!(<pre[^>]*>)(.*?)</pre>!im) do |s|
            s.gsub! '<br />', ''
            s.gsub! '<p>', "\n"
            s.gsub! '</p>', ''
            s
          end
        end
        string.gsub!(%r|\n</p>$|, '</p')

        string
      end

    end
  end
end
