# frozen_string_literal: true

require 'active_support/concern'
require_relative 'auth/settings'

module Rottweiler
  # Implements the logic for requests authentication in Rails controllers.
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action do
        next if rottweiler.skip_authentication?

        @jwt_data = rottweiler.authenticate(request)
        if @jwt_data.nil?
          rottweiler.auth_failed_cbk && instance_exec(&rottweiler.auth_failed_cbk)
          response.status = rottweiler.unauthorized_status
        elsif rottweiler.auth_success_cbk
          instance_exec(@jwt_data, &rottweiler.auth_success_cbk)
        end
      end
    end

    # Implement Rottweiler::Authentication class methods
    module ClassMethods
      attr_accessor :_rottweiler

      def rottweiler
        self._rottweiler ||= Rottweiler::Auth::Settings.new(superclass)
      end

      def skip_authentication!(**options)
        rottweiler.skip_authentication!(**options)
      end

      def on_authentication_success(&callback)
        rottweiler.auth_success_cbk = callback
      end

      def on_authentication_failed(&callback)
        rottweiler.auth_failed_cbk = callback
      end
    end

    protected

    def rottweiler
      self.class.rottweiler
    end

    def jwt_data
      @jwt_data
    end
  end
end
