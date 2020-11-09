class Admin::RdvsController < AgentAuthController
  respond_to :html, :json

  before_action :set_rdv, except: [:index, :create]

  def index
    @form = AgentRdvSearchForm.new(
      start: parse_date_from_params(:start),
      end: parse_date_from_params(:end),
      show_user_details: ["1", "true"].include?(params[:show_user_details]),
      **params.permit(:organisation_id, :agent_id, :user_id, :status)
    )
    @rdvs = policy_scope(Rdv).merge(@form.rdvs)
      .includes(:organisation, :agents_rdvs, :lieu, agents: :service, motif: :service)
      .order(starts_at: :desc)
    @breadcrumb_page = params[:breadcrumb_page]
    respond_to do |format|
      format.xls { send_data(RdvExporterService.perform_with(@rdvs, StringIO.new), filename: "rdvs.xls", type: "application/xls") }
      format.html { @rdvs = @rdvs.page(params[:page]) }
      format.json
    end
  end

  def show
    @uncollapsed_section = params[:uncollapsed_section]
    authorize(@rdv)
  end

  def edit
    authorize(@rdv)
    respond_right_bar_with(@rdv)
  end

  def update
    authorize(@rdv)
    @rdv.updated_at = Time.zone.now
    # TODO: replace this manual touch. It forces creating a version when an
    # agent or a user is removed from the RDV. the touch: true option on the
    # association does not do it for some reason I could not figure out
    @rdv.cancelled_at = nil if params[:rdv][:status]
    if params[:rdv][:status] == "excused"
      CancelRdvByAgentService.new(@rdv).perform
      flash[:notice] = "Le rendez-vous a été annulé."
    elsif @rdv.update(rdv_params)
      flash[:notice] = "Le rendez-vous a été modifié."
    end
    respond_right_bar_with @rdv, location: request.referer
  end

  def destroy
    authorize(@rdv)
    if @rdv.destroy
      flash[:notice] = "Le rendez-vous a été supprimé."
    else
      flash[:error] = "Une erreur s’est produite, le rendez-vous n’a pas pu être supprimé."
      Raven.capture_exception(Exception.new("Deletion failed for rdv : #{@rdv.id}"))
    end
    redirect_to admin_organisation_agent_path(current_organisation, current_agent)
  end

  def create
    @rdv = Rdv.new(rdv_params)
    @rdv.organisation = current_organisation
    authorize(@rdv)
    if @rdv.save
      redirect_to(
        admin_organisation_agent_path(
          current_organisation,
          @rdv.agents.include?(current_agent) ? current_agent : @rdv.agents.first,
          selected_event_id: @rdv.id,
          date: @rdv.starts_at.to_date
        ),
        notice: "Le rendez-vous a été créé."
      )
    else
      @rdv_wizard = AgentRdvWizard::Step3.new(current_agent, current_organisation, @rdv.attributes)
      render "admin/rdv_wizard_steps/step3"
    end
  end

  private

  def parse_date_from_params(param_name)
    return nil if params[param_name].blank? || params[param_name] == "__/__/____"

    Date.parse(params[param_name])
  end

  def set_rdv
    @rdv = Rdv.find(params[:id])
  end

  def rdv_params
    params.require(:rdv).permit(:motif_id, :status, :lieu_id, :duration_in_min, :starts_at, :context, agent_ids: [], user_ids: [])
  end

  def status_params
    params.require(:rdv).permit(:status)
  end
end
