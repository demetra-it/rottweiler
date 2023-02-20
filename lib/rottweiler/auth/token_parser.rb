# frozen_string_literal: true

require 'jwt'

module Rottweiler
  module Auth
    # Implements the logic for JWT token parsing
    class TokenParser
      attr_reader :request, :result

      def initialize(request)
        @request = request
        @result = nil

        verify!
      end

      def valid?
        !@result.nil?
      end

      private

      def algorithm
        @algorithm ||= Rottweiler.config.jwt.algorithm
      end

      def decode_key
        @decode_key ||= Rottweiler.config.jwt.decode_key
      end

      def verify!
        return nil if token.nil?

        body = JWT.decode(token, decode_key, true, { algorithm: algorithm })[0]
        @result = HashWithIndifferentAccess.new body
      rescue StandardError
        nil
      end

      def token
        @token ||= request.headers[Rottweiler.config.token_header] || request.dig(*Rottweiler.config.token_param)
      end
    end
  end
end
