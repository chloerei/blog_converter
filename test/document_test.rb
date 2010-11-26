require './test/helper'

class DocumentTest < Test::Unit::TestCase
  def test_init
    doc = BlogConverter::Document.new
    assert_not_nil doc
    assert_respond_to doc, :articles
    assert_equal 0, doc.articles.count
    assert_respond_to doc, :type
  end
end
