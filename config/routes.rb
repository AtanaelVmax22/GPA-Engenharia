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
    resources :curtidas, only: [:create, :destroy]
  end

  namespace :admin do
    resources :users
    get "/", to: "users#index", as: :root
  end
  
namespace :estoque do
  root "home#index"

  resources :produtos do
    member do
      get :qr
    end
  end

  resources :locais do
    member do
      get :qr
    end
  end

  resources :saldos, only: [:index] do
    collection do
      get :consulta
    end
  end

  resources :movimentacoes, only: [:index, :show, :new, :create]

  resources :recebimentos, only: [:show] do
    member do
      patch :confirmar
      patch :recusar
    end
  end

  get "locais/:local_id/recebimentos",
    to: "recebimentos#index",
    as: :local_recebimentos

  get "notificacoes/transferencias_pendentes",
    to: "notificacoes#transferencias_pendentes",
    as: :notificacoes_transferencias_pendentes

  get "scanner", to: "scanner#index", as: :scanner
  get "scanner/produto/:qr_token", to: "scanner#produto", as: :scan_produto
  get "scanner/local/:qr_token", to: "scanner#local", as: :scan_local
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