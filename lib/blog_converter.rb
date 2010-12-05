require 'nokogiri'
require 'time'
require 'blog_converter/version'
require 'blog_converter/article'
require 'blog_converter/comment'
require 'blog_converter/adaptor/blogbus'
require 'blog_converter/adaptor/wordpress'
require 'blog_converter/adaptor/xml'
require 'blog_converter/document'

module BlogConverter
  def self.parse(string)
    Document.parse string
  end
end
