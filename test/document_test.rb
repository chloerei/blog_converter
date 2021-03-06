require './test/helper'

class DocumentTest < Test::Unit::TestCase
  def setup
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read
    @blogbus_xml = File.open('./test/fixtures/blogbus.xml').read
  end

  def test_init
    doc = BlogConverter::Document.new
    assert_not_nil doc
    assert_respond_to doc, :articles
    assert_equal 0, doc.articles.count
    assert_respond_to BlogConverter::Document, :parse
  end

  def test_export_as_xml
    doc = BlogConverter::Document.parse @blogbus_xml
    assert_respond_to doc, :to_xml
    assert_not_nil doc.export
    assert_not_nil doc.export :wordpress
    assert_not_nil doc.export :blogbus
    assert_nil doc.export :undefined

    assert_not_nil doc.export(BlogConverter::Adaptor::Wordpress.new)
    assert_not_nil doc.export(:wordpress)
    assert_nil doc.export(:unknow)
  end

  def test_check_type
    assert_equal BlogConverter::Document::Type::Wordpress, BlogConverter::Document.send(:check_type, @wordpress_xml)
    assert_equal BlogConverter::Document::Type::Blogbus, BlogConverter::Document.send(:check_type, @blogbus_xml)
  end
end
