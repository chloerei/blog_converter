module BlogConverter
  class Document
    attr_accessor :articles, :type
    def initialize
      @articles = []
    end
  end
end
