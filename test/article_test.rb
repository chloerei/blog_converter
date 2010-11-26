require 'test/unit'
require 'blog_converter/article'

class ArticleTest < Test::Unit::TestCase
  def test_init
    a = BlogConverter::Article.new
    assert_not_nil a

    params = {:title => 'title', :content => 'content', :summary => 'summary', :published_at => Time.now, :created_at => Time.now, :updated_at => Time.now, :author => 'Rei'}
    a = BlogConverter::Article.new params
    params.each do |key, value|
      assert_equal value, a.send(key)
    end
  end
end
