# frozen_string_literal: true

SibApiV3Sdk.configure do |config|
  config.api_key["api-key"] = ENV["SENDINBLUE_SMS_API_KEY"]
end
