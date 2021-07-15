# frozen_string_literal: true

class AgentContext
  attr_reader :agent, :organisation, :agent_role

  delegate :can_access_others_planning?, to: :agent_role, allow_nil: true

  def initialize(agent, organisation = nil)
    @agent = agent
    @organisation = organisation
    @agent_role = AgentRole.find_by(agent: @agent, organisation: @organisation) if @organisation.present?
  end
end
