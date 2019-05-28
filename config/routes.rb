Rails.application.routes.draw do
  ## ADMIN ##
  devise_for :super_admins, controllers: { omniauth_callbacks: 'super_admins/omniauth_callbacks' }

  delete 'admin/sign_out' => 'super_admins/sessions#destroy'

  namespace :admin do
    resources :pros
    resources :super_admins
    resources :organisations
    root to: "pros#index"

    authenticate :super_admin do
      match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]
    end
  end

  ## APP ##
  devise_for :pros, controllers: { registrations: 'pros/registrations' }

  authenticated :pro do
    root to: 'agendas#index', as: :authenticated_root
  end

  { disclaimer: 'mentions_legales', terms: 'cgv' }.each do |k, v|
    get v => "static_pages##{k}"
  end
  get 'accueil_mds' => "welcome#welcome_pro"
  root 'welcome#index'
end
