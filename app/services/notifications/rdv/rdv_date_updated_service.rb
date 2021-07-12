# frozen_string_literal: true

class Notifications::Rdv::RdvDateUpdatedService < ::BaseService
  include Notifications::Rdv::BaseServiceConcern

  protected

  def notify_user_by_mail(user)
    Users::RdvMailer.rdv_date_updated(@rdv.payload(:update, user), user, @rdv.attribute_before_last_save(:starts_at)).deliver_later
    @rdv.events.create!(event_type: RdvEvent::TYPE_NOTIFICATION_MAIL, event_name: :updated)
  end

  def notify_user_by_sms(user)
    SendTransactionalSmsJob.perform_later(:rdv_updated, @rdv.payload(:update, user), user.id)
    @rdv.events.create!(event_type: RdvEvent::TYPE_NOTIFICATION_SMS, event_name: :updated)
  end

  def notify_agent(agent)
    Agents::RdvMailer.rdv_date_updated(
      @rdv.payload(:update),
      agent,
      @author,
      @rdv.attribute_before_last_save(:starts_at)
    ).deliver_later
  end
end
