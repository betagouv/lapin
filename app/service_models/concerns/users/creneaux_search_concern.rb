module Users::CreneauxSearchConcern
  extend ActiveSupport::Concern

  def next_availability
    FindAvailabilityService.perform_with(motif_name, @lieu, date_range.end, **options)
  end

  def creneaux
    CreneauxBuilderService.perform_with(motif_name, @lieu, date_range, **options)
  end

  def follow_up_motif?
    # TODO : repair motifs modelisation to remove this hack
    motifs.first&.follow_up?
  end

  protected

  def motif_name
    @motif_name ||= begin
      raise unless motifs.pluck(:name).uniq.count == 1 # safety net

      motifs.first.name
    end
  end

  def options
    @options ||= {
      agent_ids: agent_ids,
      agent_name: follow_up_rdv_and_online_user? || nil,
      motif_location_type: motif_location_type
    }.compact
  end

  def agent_ids
    @agent_ids ||= follow_up_rdv_and_online_user? ? @user.agent_ids : nil
  end

  def follow_up_rdv_and_online_user?
    @user && follow_up_motif?
  end
end
