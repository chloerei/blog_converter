require './test/helper.rb'

class AdaptorWordpressTest < Test::Unit::TestCase
  def setup
    @adaptor =BlogConverter::Adaptor::Wordpress.new
  end

  def test_export
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read
    @doc = @adaptor.import @wordpress_xml
    @xml = @adaptor.export @doc
    @new_doc = @adaptor.import @xml
    assert_equal @doc.articles.count, @new_doc.articles.count
    assert_equal @doc.articles.first.status, @new_doc.articles.first.status
    assert_equal @doc.articles.first.categories, @new_doc.articles.first.categories
    assert_equal @doc.articles.first.tags, @new_doc.articles.first.tags
    assert_equal @doc.articles.first.comments.count, @new_doc.articles.first.comments.count
  end

  def test_import
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read

    doc = @adaptor.import @wordpress_xml
    assert_equal BlogConverter::Document, doc.class

    assert_equal 1, doc.articles.count
    article = doc.articles.first
    assert_equal BlogConverter::Article::Status::Publish, article.status
    assert_equal 'Hello world!', article.title
    assert_equal 'Rei', article.author
    assert_equal @adaptor.wpautop_filter('Welcome to <a href="http://blog.chloerei.com/">Blog.chloerei.com</a>. This is your first post. Edit or delete it, then start blogging!'), article.content
    assert_equal Time, article.created_at.class
    assert_equal Time, article.published_at.class
    assert_equal 'Uncategorized', article.categories.first
    assert_equal 1, article.comments.count
    comment = article.comments.first
    assert_equal 'Mr WordPress', comment.author
    assert_equal '', comment.email
    assert_equal 'http://test.domain/', comment.url
    assert_equal Time, comment.created_at.class
    assert_equal @adaptor.wpautop_filter('This is an example of a WordPress comment'), comment.content
  end

  def test_wpautop_filter
    assert_equal "", @adaptor.wpautop_filter('<br /><br />')
    assert_equal "<table></table>\n", @adaptor.wpautop_filter('<table></table>')
    assert_equal "<p>a<br />\na</p>\n", @adaptor.wpautop_filter("a\ra")
    assert_equal "<p><object><param url='test' /></object></p>\n", @adaptor.wpautop_filter("<object> <param url='test' /></object>")
    assert_equal "<p></embed></p>\n", @adaptor.wpautop_filter(" </embed> ")
    assert_equal "<p>a</p>\n<p>a</p>\n", @adaptor.wpautop_filter("a\n\n\na")
    assert_equal "<pre>\n\n</pre>\n", @adaptor.wpautop_filter("<pre><p></p><br /></pre>")

  end
end
