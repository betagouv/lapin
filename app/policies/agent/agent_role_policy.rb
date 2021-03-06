# frozen_string_literal: true

class Agent::AgentRolePolicy < ApplicationPolicy
  include CurrentAgentInPolicyConcern

  def current_agent_admin_in_record_organisation?
    agent_role_in_record_organisation&.admin?
  end

  alias create? current_agent_admin_in_record_organisation?
  alias edit? current_agent_admin_in_record_organisation?
  alias update? current_agent_admin_in_record_organisation?

  private

  def agent_role_in_record_organisation
    @agent_role_in_record_organisation ||= \
      current_agent.roles.find_by(organisation_id: record.organisation_id)
  end

  class Scope < Scope
    include CurrentAgentInPolicyConcern

    def resolve
      current_agent.roles.map do |agent_role|
        if agent_role.admin?
          scope.where(organisation_id: agent_role.organisation_id)
        else
          scope.where(organisation_id: agent_role.organisation_id, agent_id: current_agent.id)
        end
      end.reduce(:or)
    end
  end
end
