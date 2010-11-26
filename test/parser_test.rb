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

  def test_wordpress_inport
    doc = BlogConverter::Parser.parse @wordpress_xml
    assert_equal BlogConverter::Parser::Type::Wordpress, doc.type
    assert_equal 1, doc.articles.count
  end
end
