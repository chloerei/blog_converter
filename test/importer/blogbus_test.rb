require './test/helper'

class ImporterBlogbusTest < Test::Unit::TestCase
  def test_import
    @blogbus_xml = File.open('./test/fixtures/blogbus.xml').read
    doc = BlogConverter::Importer::Blogbus.import @blogbus_xml
    assert_equal BlogConverter::Document, doc.class
    assert_equal 1, doc.articles.count
    article = doc.articles.first
    assert_equal 'title', article.title
    assert_equal '', article.author
    assert_equal '<p>test content</p>', article.content
    assert_equal '<p>test content</p>', article.summary
    assert_equal 'category', article.categories.first
    assert_equal ['tag', 'tag2'].sort, article.tags.sort
    assert_equal 1, article.comments.count
    comment = article.comments.first
    assert_equal 'Rei', comment.author
    assert_equal 'test@test.domain', comment.email
    assert_equal 'test comment', comment.content
  end
end
