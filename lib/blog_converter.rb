require 'nokogiri'
require 'time'
require 'blog_converter/article'
require 'blog_converter/comment'
require 'blog_converter/document'
require 'blog_converter/importer/wordpress'
require 'blog_converter/exporter/wordpress'

module BlogConverter

  def self.parse(string)
    Document.parse string
  end
end
