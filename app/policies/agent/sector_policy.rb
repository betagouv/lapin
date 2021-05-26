# frozen_string_literal: true

class Agent::SectorPolicy < ApplicationPolicy
  alias context pundit_user
  delegate :agent, to: :context, prefix: :current # defines current_agent

  def agent_has_role_in_record_territory?
    current_agent.territorial_roles.pluck(:territory_id).include?(record.territory_id)
  end

  alias new? agent_has_role_in_record_territory?
  alias create? agent_has_role_in_record_territory?
  alias show? agent_has_role_in_record_territory?
  alias edit? agent_has_role_in_record_territory?
  alias update? agent_has_role_in_record_territory?
  alias destroy? agent_has_role_in_record_territory?

  class Scope < Scope
    alias context pundit_user
    delegate :agent, to: :context, prefix: :current # defines current_agent

    def resolve
      scope
        .joins(:territory)
        .where(territories: { id: current_agent.territorial_roles.pluck(:territory_id) })
    end
  end
end
