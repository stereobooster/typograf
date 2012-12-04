require "typograf/version"
require "typograf/client"

module Typograf
  def self.process(text, options = {})
    Client.new(options).send_request(text)
  end
end
