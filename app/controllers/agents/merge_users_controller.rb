class Agents::MergeUsersController < AgentAuthController
  before_action :set_organisation

  def new
    user1 = policy_scope(User).find(params[:user1_id]) if params[:user1_id].present?
    user2 = policy_scope(User).find(params[:user2_id]) if params[:user2_id].present?
    @merge_users_form = MergeUsersForm.new(current_organisation, user1: user1, user2: user2)
    skip_authorization
  end

  def create
    user1 = policy_scope(User).find(params[:merge_users_form][:user1_id])
    user2 = policy_scope(User).find(params[:merge_users_form][:user2_id])
    authorize(user1)
    authorize(user2)
    @merge_users_form = MergeUsersForm.new(current_organisation, user1: user1, user2: user2, **merge_users_params)
    if @merge_users_form.save
      redirect_to organisation_user_path(current_organisation, @merge_users_form.user_target), flash: { success: "Les usagers ont été fusionnés" }
    else
      render :new
    end
  end

  protected

  def merge_users_params
    params.require(:merge_users_form).permit(MergeUsersForm::ATTRIBUTES)
  end
end
