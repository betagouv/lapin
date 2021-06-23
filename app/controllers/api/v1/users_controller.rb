# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::BaseController
  PERMITTED_PARAMS = %i[
    first_name birth_name last_name email address phone_number invite_for
    birth_date responsible_id caisse_affiliation affiliation_number
    family_situation number_of_children notify_by_sms notify_by_email
  ].freeze

  def show
    user = User.find(params[:id])
    authorize(user)
    render json: UserBlueprint.render(user, root: :user, agent_context: pundit_user)
  end

  def create
    params.require(:organisation_ids)

    user = User.new(**user_params, created_through: "agent_creation_api")
    authorize(user)
    user.skip_confirmation_notification!
    user.save!
    render json: UserBlueprint.render(user, root: :user)
  end

  def invite
    @user = User.find(params[:id])
    authorize(@user)
    @user.invite_for = user_params[:invite_for]
    @user.invite! do |u|
      u.skip_invitation = true
      u.invited_by = pundit_user.agent
    end
  end

  private

  def user_params
    params.permit(*PERMITTED_PARAMS, organisation_ids: [])
  end
end
