module BlogConverter
  class Comment
    attr_accessor :author, :email, :url, :content, :created_at, :ip

    def initialize(params = {})
      %w( author email url content created_at ip ).each do |column|
        send "#{column}=", params[column.to_sym]
      end
    end
  end
end
