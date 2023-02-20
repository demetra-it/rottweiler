# frozen_string_literal: true

require_relative 'rottweiler/version'
require_relative 'rottweiler/configuration'
require_relative 'rottweiler/authentication'

# Rottweiler is a Ruby gem for easy verification of JSON Web Tokens (JWTs) in Rails applications.
module Rottweiler
  class Error < StandardError; end
  class InvalidParamsError < StandardError; end

  class << self
    # Allows to configure Rottweiler gem:
    #
    #   Rottweiler.config do |config|
    #     config.token_header = 'Authorization'
    #     config.token_param = [:token]
    #
    #     config.jwt.algorithm = 'RS256'
    #     config.jwt.decode_key = '--- RSA PUBLIC KEY ---'
    #   end
    #
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
