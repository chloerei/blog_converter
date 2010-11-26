module BlogConverter
  class Comment
    attr_accessor :author, :email, :url, :content, :created_at

    def initialize(params = {})
      %w( author email url content created_at ).each do |column|
        send "#{column}=", params[column.to_sym]
      end
    end
  end
end
