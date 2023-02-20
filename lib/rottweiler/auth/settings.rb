# frozen_string_literal: true

require_relative 'token_parser'

module Rottweiler
  module Auth
    # Implements the logic for requests authentication in Rails controllers.
    class Settings
      attr_writer :auth_failed_cbk, :auth_success_cbk

      def initialize(superklass)
        @super_params = superklass.rottweiler if superklass.respond_to?(:rottweiler)
        reset!
      end

      def reset!
        @auth_failed_cbk = nil
        @auth_success_cbk = nil
        reset_skip!
      end

      def reset_skip!
        @skip = { only: [], except: [], all: false }
      end

      def skip_authentication!(only: nil, except: nil)
        raise Rottweiler::InvalidParamsError, 'You can only use `only` or `except`, not both' if only && except

        reset_skip!

        @skip[:only] = sanitize_action_names(only)
        @skip[:except] = sanitize_action_names(except)
        @skip[:all] = true if only.nil?
      end

      def skip_authentication?(action_name)
        action_name = action_name.to_sym

        # Use the most local value if it's set, otherwise use the value from the superclass
        return true if @skip[:only].include?(action_name)
        return true if @skip[:all] && !@skip[:except].include?(action_name)

        # If there's no superclass, return false, otherwise return the value from the superclass
        return @super_params.skip_authentication?(action_name) unless @super_params.nil?

        false
      end

      def auth_failed_cbk
        @auth_failed_cbk || @super_params&.auth_failed_cbk
      end

      def auth_success_cbk
        @auth_success_cbk || @super_params&.auth_success_cbk
      end

      def authenticate(request)
        TokenParser.new(request).result
      end

      private

      def sanitize_action_names(action_names)
        return [] if action_names.nil?

        [action_names].flatten.map do |action_name|
          unless [Symbol, String].include?(action_name.class)
            raise Rottweiler::InvalidParamsError, 'Action name must be a Symbol or a String'
          end

          action_name.to_sym
        end
      end
    end
  end
end
