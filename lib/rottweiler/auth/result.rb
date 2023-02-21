# frozen_string_literal: true

require 'jwt'

module Rottweiler
  module Auth
    # Implements the logic for JWT token parsing
    class Result
      attr_reader :request, :result, :errors

      def initialize(request)
        @request = request
        @result = nil
        @errors = []

        check_decode_key!
        verify! if errors.empty?
      end

      def valid?
        @errors.empty?
      end

      private

      def algorithm
        @algorithm ||= Rottweiler.config.jwt.algorithm
      end

      def decode_key
        @decode_key ||= Rottweiler.config.jwt.decode_key
      end

      def check_decode_key!
        return true unless decode_key.nil?

        add_error(:decode_key, 'JWT decode key is not configured')
        false
      end

      def verify!
        if token.nil?
          add_error(:token_missing, 'No JWT token found')
          return
        end

        body = JWT.decode(token, decode_key, true, { algorithm: algorithm })[0]
        @result = HashWithIndifferentAccess.new body
      rescue JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError => e
        handle_jwt_error(e)
      rescue StandardError => e
        Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
        add_error(:jwt_verification_error, "Failed to verify JWT token: #{e.class}")
      end

      def token
        return @token if defined?(@token)

        @token = request.headers[Rottweiler.config.token_header] || request.params.dig(*Rottweiler.config.token_param)
        @token = @token&.split(' ')&.last
        @token
      end

      def add_error(key, message)
        errors << { key => message }
      end

      def handle_jwt_error(error)
        case error
        when JWT::ExpiredSignature
          add_error(:token_expired, 'JWT token is expired')
        when JWT::DecodeError
          add_error(:invalid_token_format, 'JWT token has invalid format')
        when JWT::VerificationError
          add_error(:invalid_token_signature, 'JWT token has invalid signature')
        end
      end
    end
  end
end
