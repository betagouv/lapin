class FileAttente < ApplicationRecord
  belongs_to :rdv
  belongs_to :user
  validates :rdv, uniqueness: { scope: :user }

  NO_MORE_NOTIFICATIONS = 7.days
  MAX_NOTIFICATIONS = 3

  scope :active, -> { joins(:rdv).where("rdvs.starts_at > ?", NO_MORE_NOTIFICATIONS.from_now).order(created_at: :desc) }

  def self.send_notifications
    FileAttente.active.each do |fa|
      next if fa.rdv.motif.phone?

      end_time = fa.rdv.starts_at - 2.day
      date_range = Date.today..end_time.to_date
      creneaux = fa.rdv.creneaux_available(date_range)
      next unless fa.valid_for_notification?(creneaux)

      fa.send_notification
    end
  end

  def valid_for_notification?(creneaux)
    !creneaux.empty? && notifications_sent < MAX_NOTIFICATIONS && (last_creneau_sent_at.nil? || last_creneau_sent_at.to_date < Date.today)
  end

  def send_notification
    rdv.users.map(&:user_to_notify).uniq.each do |user|
      SendTransactionalSmsJob.perform_later(:file_attente, rdv.id, user.id) if user.phone_number_formatted
      Users::FileAttenteMailer.new_creneau_available(rdv, user).deliver_later if user.email
      update!(notifications_sent: notifications_sent + 1, last_creneau_sent_at: Time.now)
    end
  end
end
