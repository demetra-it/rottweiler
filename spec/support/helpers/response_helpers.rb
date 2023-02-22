# frozen_string_literal: true

module ResponseHelpers
  def json_body
    HashWithIndifferentAccess.new JSON.parse(response.body)
  end

  def auth_errors
    json_body['errors']
  end
end

RSpec.configure do |config|
  config.include ResponseHelpers, type: :controller
end
