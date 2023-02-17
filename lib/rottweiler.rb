# frozen_string_literal: true

require_relative 'rottweiler/version'
require_relative 'rottweiler/configuration'

# Rottweiler is a Ruby gem for easy verification of JSON Web Tokens (JWTs) in Rails applications.
module Rottweiler
  class Error < StandardError; end

  # Configuration:
  #
  #  Rottweiler.config do |config|
  #    config.token_header = 'Authorization'
  #    config.token_param = [:token]
  # end
  class << self
    def config(&block)
      config_instance = Configuration.instance

      if block_given?
        block.call(config_instance)
      else
        config_instance
      end
    end
  end
end
