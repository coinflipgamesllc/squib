# typed: true
require_relative 'arg_loader'

module Squib::Args
  class EmbedKey

    # Validate the embed lookup key
    def validate_key(str)
      str.to_s
    end
    
  end
end
