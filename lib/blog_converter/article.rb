module BlogConverter
  class Article
    attr_accessor :title, :content, :summary, :published_at, :created_at, :updated_at, :author, :comments

    def initialize(params = {})
      %w( title content summary published_at created_at updated_at author ).each do |column|
        send("#{column}=", params[column.to_sym])
      end
      @comments = []
    end
  end
end
