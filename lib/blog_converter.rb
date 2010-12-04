require 'nokogiri'
require 'time'
require 'blog_converter/article'
require 'blog_converter/comment'
require 'blog_converter/document'
require 'blog_converter/importer/wordpress'
require 'blog_converter/importer/blogbus'
require 'blog_converter/exporter/wordpress'
require 'blog_converter/exporter/blogbus'

module BlogConverter
  def self.version
    '0.1.1'
  end

  def self.parse(string)
    Document.parse string
  end
end
