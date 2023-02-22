# frozen_string_literal: true

require 'jwt'

module Rottweiler
  module Auth
    # Implements the logic for JWT token parsing
    class Result
      attr_reader :request, :data, :errors

      def initialize(request)
        @request = request
        @data = nil
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
        @data = HashWithIndifferentAccess.new body
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::IncorrectAlgorithm, JWT::DecodeError => e
        handle_jwt_error(e)
      rescue StandardError => e
        handle_generic_error(e)
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
        when JWT::VerificationError
          add_error(:invalid_token_signature, 'JWT token has invalid signature')
        when JWT::IncorrectAlgorithm
          add_error(:invalid_token_algorithm, 'JWT token has invalid algorithm')
        when JWT::DecodeError
          add_error(:invalid_token_format, 'JWT token has invalid format')
        end
      end

      def handle_generic_error(error)
        Rails.logger.error "#{error.message}\n#{error.backtrace.join("\n")}"
        add_error(:jwt_verification_error, "Failed to verify JWT token: #{error.class}")
      end
    end
  end
end
