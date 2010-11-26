require 'test/unit'
require 'blog_converter'

class BlogConverterTest < Test::Unit::TestCase
  def test_init
    conv = BlogConverter.new
    assert_not_nil conv
  end
end
