class Agent::RdvPolicy < DefaultAgentPolicy
  def status?
    same_agent_or_has_access?
  end

  class Scope < Scope
    def resolve
      if @context.agent.can_access_others_planning?
        scope.active.where(organisation_id: @context.organisation.id)
      else
        scope.active.joins(:agents).where(organisation_id: @context.organisation.id, agents: { id: @context.agent.id })
      end
    end
  end
end
