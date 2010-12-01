require './test/helper'

class BlogConverterTest < Test::Unit::TestCase
  def test_parse
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read
    doc = BlogConverter.parse @wordpress_xml
    assert_equal BlogConverter::Document, doc.class
  end
end
