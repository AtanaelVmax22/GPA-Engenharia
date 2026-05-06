Rails.application.routes.draw do
  devise_for :users, path: "", path_names: { sign_in: "login", sign_out: "logout", sign_up: "cadastro" }

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :condominios do
    resources :equipamentos, shallow: true
    resources :historico_tecnicos, shallow: true
    resources :checklists, shallow: true do
      resources :checklist_items, only: [:create, :update, :destroy]
    end
  end

  resources :post_tecnicos do
    resources :comentarios, only: [:create, :destroy]
  end

  namespace :admin do
    resources :users
    get "/", to: "users#index", as: :root
  end

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :condominios, only: [:index, :show]
      resources :equipamentos, only: [:index, :show]
      resources :historico_tecnicos, only: [:index, :show, :create]
      resources :checklists, only: [:index, :show, :update]
      resources :post_tecnicos, only: [:index, :show, :create]
    end
  end
end
