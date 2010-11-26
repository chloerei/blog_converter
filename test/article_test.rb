require './test/helper'

class ArticleTest < Test::Unit::TestCase
  def setup
    @article = BlogConverter::Article.new 
  end

  def test_init
    a = BlogConverter::Article.new
    assert_not_nil a

    params = {:title => 'title', :content => 'content', :summary => 'summary', :published_at => Time.now, :created_at => Time.now, :author => 'Rei', :categories => ["live"], :tags => ["tag1", "tag2"]}
    a = BlogConverter::Article.new params
    params.each do |key, value|
      assert_equal value, a.send(key)
    end
  end

  def test_comments
    assert @article.comments.empty?
    cm = BlogConverter::Comment.new
    @article.comments << cm
    assert_equal 1, @article.comments.count
  end
end
