class DefaultAgentPolicy
  attr_reader :context, :record

  def initialize(context, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless context.agent
    if context.organisation && context.agent.organisation_ids.exclude?(context.organisation.id)
      raise Pundit::NotAuthorizedError, "must be of the same organisation"
    end

    @context = context
    @record = record
  end

  def index?
    false
  end

  def show?
    same_agent_or_has_access?
  end

  def create?
    same_agent_or_has_access?
  end

  def cancel?
    same_agent_or_has_access?
  end

  def new?
    create?
  end

  def update?
    same_agent_or_has_access?
  end

  def edit?
    update?
  end

  def destroy?
    same_agent_or_has_access?
  end

  def same_org?
    return false if @context.organisation.nil?

    if @record.respond_to?(:organisation_id)
      @record.organisation_id == @context.organisation.id
    elsif @record.respond_to?(:organisation_ids)
      @record.organisation_ids.include?(@context.organisation.id)
    else
      false
    end
  end

  def same_service?
    if @record.is_a?(Agent) || @record.is_a?(Motif)
      @record.service_id == @context.agent.service_id
    elsif @record.respond_to?(:agent_id)
      @record.agent.service_id == @context.agent.service_id
    elsif @record.respond_to?(:agent_ids)
      Agent.where(id: @record.agent_ids).pluck(:service_id).uniq == [@context.agent.service_id]
    end
  end

  def same_agent?
    if @record.is_a? Agent
      @record.id == @context.agent.id
    elsif @record.respond_to?(:agent_id)
      @record.agent_id == @context.agent.id
    elsif @record.respond_to?(:agent_ids)
      @record.agent_ids.include?(@context.agent.id)
    else
      false
    end
  end

  def admin?
    @context.agent.admin?
  end

  def admin_and_same_org?
    admin? && same_org?
  end

  def same_agent_or_has_access?
    if same_agent?
      true
    elsif same_org?
      same_service? || @context.agent.can_access_others_planning?
    else
      false
    end
  end

  class Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @scope = scope
    end

    def resolve
      scope.where(agent_id: @context.agent.id, organisation_id: @context.organisation.id)
    end

    def in_scope?(object)
      return false unless object&.id.present?

      resolve.where(id: object.id).any?
    end
  end
end
