class Admin::Users::RdvsController < AgentAuthController
  def index
    @user = policy_scope(User).find(params[:user_id])
    @rdvs = @user.rdvs
    @rdvs = @rdvs.status(params[:status]) if params[:status].present?
    @rdvs = @rdvs.includes(:organisation, :motif, :agents_rdvs, agents: :service).order(starts_at: :desc).page(params[:page])
  end
end
