class WelcomeController < ApplicationController
  before_action :set_lieu_variables, only: [:welcome_departement, :welcome_service]

  layout 'welcome'

  def index; end

  def welcome_agent
    render layout: 'welcome_agent'
  end

  def search
    search_params = params.require(:search).permit(:departement, :where, :service, :motif_name, :latitude, :longitude)

    if search_params[:service].present?
      if search_params[:motif_name].present?
        redirect_to lieux_path(search: { departement: search_params[:departement], service: search_params[:service], motif_name: search_params[:motif_name], where: search_params[:where], latitude: search_params[:latitude], longitude: search_params[:longitude] })
      else
        redirect_to welcome_service_path(search_params[:departement], search_params[:service], where: search_params[:where], latitude: search_params[:latitude], longitude: search_params[:longitude])
      end
    elsif search_params[:departement].present?
      redirect_to welcome_departement_path(search_params[:departement], where: search_params[:where], latitude: search_params[:latitude], longitude: search_params[:longitude])
    else
      flash[:error] = "L'adresse entrée n'est pas valide. Vous devez choisir une des valeurs proposées sur le champ adresse."
      redirect_to root_path
    end
  end

  def welcome_departement
    @services = Service.with_online_and_active_motifs_for_departement(@departement)
  end

  def welcome_service
    @motif_names = Motif.names_for_service_and_departement(@service, @departement)
  end

  def set_lieu_variables
    lieu_params = params.permit(:departement, :where, :service, :latitude, :longitude)
    @departement = lieu_params[:departement]
    @latitude = lieu_params[:latitude]
    @longitude = lieu_params[:longitude]
    @where = lieu_params[:where]
    @service = Service.find(lieu_params[:service]) if lieu_params[:service]
  end
end
