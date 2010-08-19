module Exceptions

  class PermissionError < SecurityError
      attr_accessor :resource_type, :id

      def initialize(message,resource_type=nil,id=nil)
        super message
        self.id = id
        self.resource_type = resource_type
      end
  end

  class PhotoFileTypeError < TypeError
  end
  
  class AuthorizeNetError < StandardError
  end

end
