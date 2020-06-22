class SmsSenderJob < ApplicationJob
  def perform(status, rdv, user, options = {})
    TransactionnalSms.new(status, rdv, user, options).send_sms if Rails.env.production?
  end
end
