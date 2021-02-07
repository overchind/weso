# frozen_string_literal: true

require_relative './client'

module Weso
  # ::nodoc::
  module Base
    def self.connect(url, options = {})
      client = Weso::Base::Client.new
      yield client if block_given?
      client.connect(url, options)
    end
  end
end
