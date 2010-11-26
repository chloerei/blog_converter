module BlogConverter
  class Comment
    attr_accessor :name, :email, :url, :content, :created_at

    def initialize(params = {})
      %w( name email url content created_at ).each do |column|
        send "#{column}=", params[column.to_sym]
      end
    end
  end
end
