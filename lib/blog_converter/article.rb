module BlogConverter
  class Article
    attr_accessor :title, :content, :summary, :published_at, :created_at, :author, :comments, :categories, :tags, :status

    module Status
      Publish = 'publish'
      Draft   = 'draft'
      Hide    = 'hide'
      Top     = 'top'
    end

    def initialize(params = {})
      %w( title content summary published_at created_at author categories tags status ).each do |column|
        send("#{column}=", params[column.to_sym])
      end
      @categories ||= []
      @tags       ||= []
      @comments   ||= []
    end
  end
end
