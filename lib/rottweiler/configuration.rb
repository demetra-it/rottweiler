# frozen_string_literal: true

require_relative 'configs/jwt'

module Rottweiler
  # `Configuration` class allows to store and retrieve current Rottweiler configuration.
  class Configuration
    def self.instance
      @instance ||= Configuration.new
    end

    attr_accessor :token_header, :token_param, :unauthorized_status

    attr_reader :jwt

    def initialize
      @token_header = 'Authorization'
      @token_param = [:token]
      @unauthorized_status = :unauthorized
      @jwt = Configs::JWT.new
    end
  end
end
