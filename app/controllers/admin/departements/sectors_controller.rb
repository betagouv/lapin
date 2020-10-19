class Admin::Departements::SectorsController < AgentDepartementAuthController
  def index
    @sectors = policy_scope(Sector)
      .where(departement: current_departement.number)
      .order(:name)
      .includes(:attributions)
    @sectors = @sectors.page(params[:page]) unless params[:view] == "map"
    authorize(@sectors)
    render :index_map if params[:view] == "map"
  end

  def new
    @sector = Sector.new(departement: current_departement)
    authorize(@sector)
  end

  def create
    @sector = Sector.new(**sector_params, departement: current_departement)
    authorize(@sector)
    if @sector.save
      redirect_to admin_departement_sectors_path(current_departement), flash: { success: "Secteur créé" }
    else
      render :new
    end
  end

  def show
    @sector = Sector.find(params[:id])
    @new_sector_attribution = SectorAttribution.new(sector: @sector)
    authorize(@sector)
    @zones = @sector.zones.page(params[:page])
  end

  def edit
    @sector = Sector.find(params[:id])
    authorize(@sector)
  end

  def update
    @sector = Sector.find(params[:id])
    @sector.assign_attributes(**sector_params)
    authorize(@sector)
    if @sector.save
      redirect_to admin_departement_sectors_path(current_departement), flash: { success: "Commune mise à jour" }
    else
      render :edit
    end
  end

  def destroy
    sector = Sector.find(params[:id])
    authorize(sector)
    if sector.destroy
      redirect_to admin_departement_sectors_path(current_departement), flash: { success: "Secteur supprimé" }
    else
      redirect_to admin_departement_sectors_path(current_departement), flash: { error: "Erreur lors de la suppression" }
    end
  end

  private

  def sector_params
    params.require(:sector).permit(:departement, :name, :human_id)
  end
end
