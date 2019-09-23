class PlageOuverture < ApplicationRecord
  require "montrose"

  serialize :start_time, Tod::TimeOfDay
  serialize :end_time, Tod::TimeOfDay
  serialize :recurrence, Montrose::Recurrence

  belongs_to :organisation
  belongs_to :pro
  belongs_to :lieu
  has_and_belongs_to_many :motifs, -> { distinct }

  before_save :clear_empty_recurrence

  validate :end_after_start

  scope :exceptionnelles, -> { where(recurrence: nil) }
  scope :regulieres, -> { where.not(recurrence: nil) }

  def start_at
    start_time.on(first_day)
  end

  def end_at
    end_time.on(first_day)
  end

  def time_shift
    Tod::Shift.new(start_time, end_time)
  end

  def time_shift_duration_in_min
    time_shift.duration / 60
  end

  def occurences_for(inclusive_date_range)
    recurrence_until = recurrence&.to_hash&.[](:until)
    min_until = [inclusive_date_range.end, recurrence_until].compact.min.to_time.end_of_day

    if recurrence.present?
      recurrence.starting(start_at).until(min_until).lazy.select { |o| o >= inclusive_date_range.begin.to_time }.to_a
    else
      [start_at].select { |t| inclusive_date_range.cover?(t) }
    end
  end

  def exceptionnelle?
    recurrence.nil?
  end

  def self.for_motif_and_lieu_from_date_range(motif_name, lieu, inclusive_date_range)
    motifs_ids = Motif.where(name: motif_name, organisation_id: lieu.organisation_id)
    PlageOuverture.includes(:motifs_plageouvertures).where(lieu: lieu).where("first_day <= ?", inclusive_date_range.begin).joins(:motifs).where(motifs: { id: motifs_ids }).includes(:motifs).uniq
  end

  private

  def clear_empty_recurrence
    self.recurrence = nil if recurrence.present? && recurrence.to_hash == {}
  end

  def end_after_start
    return if end_time.blank? || start_time.blank?

    errors.add(:end_time, "doit être après l'heure de début") if end_time <= start_time
  end
end
