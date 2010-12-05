require './test/helper.rb'

class AdaptorXmlTest < Test::Unit::TestCase
  def setup
    @doc = BlogConverter::Document.new
    @article = BlogConverter::Article.new :title => 'test', :content => 'test', :author => 'Rei'
    @comment = BlogConverter::Comment.new :author => 'Rei', :content => 'test'
    @article.comments << @comment
    @doc.articles << @article
    @adaptor =BlogConverter::Adaptor::Xml.new
  end

  def test_export_and_import
    xml = @adaptor.export @doc
    @new_doc = @adaptor.import xml
    assert_equal @doc.to_xml, @new_doc.to_xml
  end
end
