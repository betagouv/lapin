class Users::RdvsController < UserAuthController
  before_action :set_rdv, only: [:confirmation, :cancel]

  def index
    @rdvs = policy_scope(Rdv).includes(:motif, :rdvs_users, :users)
    @rdvs = params[:past].present? ? @rdvs.past : @rdvs.future
    @rdvs = @rdvs.order(starts_at: :desc).page(params[:page])
  end

  def new
    rdv_defaults = {
      user_ids: [params[:created_user_id].presence || current_user.id],
    }
    @motif_name = new_rdv_extra_params[:motif_name]
    @departement = new_rdv_extra_params[:departement]
    @where = new_rdv_extra_params[:where]
    @lieu = Lieu.find(new_rdv_extra_params[:lieu_id])
    @motif = Motif.find_by(organisation_id: @lieu.organisation_id, name: @motif_name)
    @rdv = Rdv.new(rdv_defaults.merge(rdv_params).merge(motif: @motif))
    @creneau = Creneau.new(starts_at: @rdv.starts_at, motif: @motif, lieu_id: @lieu.id)
    authorize(@rdv)
    @query = { where: @where, service: @motif.service.id, motif: @motif_name, departement: @departement }
    return if @creneau.available?

    flash[:error] = "Ce créneau n'est plus disponible. Veuillez en sélectionner un autre."
    redirect_to lieux_path(search: { departement: @departement, service: @motif.service.id, motif: @motif_name, where: @where })
  end

  def create
    @motif = Motif.find(creneau_params[:motif_id])
    @starts_at = DateTime.parse(creneau_params[:starts_at])
    @creneau = Creneau.new(starts_at: @starts_at, motif: @motif, lieu_id: creneau_params[:lieu_id])
    @user = user_for_rdv
    save_succeeded = false
    ActiveRecord::Base.transaction do
      @rdv = @creneau.to_rdv_for_user(@user)
      save_succeeded = if @rdv.present?
                         @rdv.created_by = :user
                         authorize(@rdv)
                         @rdv.save
                       else
                         skip_authorization
                         false
                       end
    end
    if save_succeeded
      redirect_to users_rdv_confirmation_path(@rdv.id)
    else
      query = { where: new_rdv_extra_params[:where], service: motif.service.id, motif_name: motif.name, departement: new_rdv_extra_params[:departement] }
      flash[:error] = "Ce creneau n'est plus disponible. Veuillez en sélectionner un autre."
      redirect_to lieux_path(search: { departement: creneau_params[:departement], service: @motif.service.id, motif: @motif.name, where: creneau_params[:where] })
    end
  end

  def confirmation
    authorize(@rdv)
  end

  def cancel
    authorize(@rdv)
    if @rdv.cancel
      @rdv.file_attentes.destroy_all
      flash[:notice] = "Le RDV a bien été annulé."
    else
      flash[:error] = "Impossible d'annuler le RDV."
    end
    redirect_to users_rdvs_path
  end

  private

  def set_rdv
    @rdv = policy_scope(Rdv).find(params[:rdv_id])
  end

  def user_for_rdv
    if creneau_params[:user_ids]
      current_user.available_users_for_rdv.find(creneau_params[:user_ids])
    else
      current_user
    end
  end

  def new_rdv_extra_params
    params.permit(:lieu_id, :motif_name, :departement, :where)
  end

  def rdv_params
    params.permit(:starts_at, user_ids: [])
  end

  def creneau_params
    params.require(:rdv).permit(:motif_id, :lieu_id, :starts_at, :departement, :where, :user_ids)
  end
end
