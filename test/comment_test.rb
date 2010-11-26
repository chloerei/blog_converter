require './test/helper'

class CommentTest < Test::Unit::TestCase
  def setup
    @params = {:author => 'name', :email => 'email', :url => 'url', :content => 'content', :created_at => Time.now}
    @comment = BlogConverter::Comment.new @params
  end

  def test_init
    @params.each do |key, value|
      assert_equal value, @comment.send("#{key}")
    end
  end
end
