# encoding: UTF-8
require './test/helper.rb'

class ParserTest < Test::Unit::TestCase
  def setup
    @xml = <<EOF
    <?xml version="1.0" encoding="utf-8"?>
EOF
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read
  end

  def test_parse
    doc = BlogConverter::Parser.parse @xml
    assert_equal BlogConverter::Document, doc.class
  end

  def test_wordpress_import
    doc = BlogConverter::Parser.parse @wordpress_xml
  end
end
