# frozen_string_literal: true

module Rottweiler
  # `Configuration` class allows to store and retrieve current Rottweiler configuration.
  class Configuration
    def self.instance
      @instance ||= Configuration.new
    end

    attr_accessor :token_header, :token_param, :unauthorized_status

    def initialize
      @token_header = 'Authorization'
      @token_param = [:token]
      @unauthorized_status = :unauthorized
    end

    def kafka_config=(**configs)
      @kafka_config = configs
    end
  end
end
