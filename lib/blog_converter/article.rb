module BlogConverter
  class Article
    attr_accessor :title, :content, :summary, :published_at, :created_at, :author, :comments, :categories, :tags

    def initialize(params = {})
      %w( title content summary published_at created_at author categories tags).each do |column|
        send("#{column}=", params[column.to_sym])
      end
      @comments = []
    end
  end
end
