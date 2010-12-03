require './test/helper'

class BlogConverterTest < Test::Unit::TestCase
  def setup
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read
    @blogbus_xml = File.open('./test/fixtures/blogbus.xml').read
  end

  def test_parse
    doc = BlogConverter.parse @wordpress_xml
    assert_equal BlogConverter::Document, doc.class
  end

end
