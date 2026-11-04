
Rails.application.routes.draw do

  # ==========================================
  # AUTENTICAÇÃO
  # ==========================================

  devise_for :users,
    path: "",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      sign_up: "cadastro"
    }

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  # ==========================================
  # DASHBOARD
  # ==========================================

  get "dashboard",
    to: "dashboard#index",
    as: :dashboard

  # ==========================================
  # CONDOMÍNIOS
  # ==========================================

  resources :condominios do

    # Equipamentos
    resources :equipamentos, shallow: true

    # Histórico Técnico
    resources :historico_tecnicos, shallow: true do

      # Exclusão individual de fotos
      member do
        delete "fotos/:foto_id",
          action: :remover_foto,
          as: :remover_foto
      end

    end

    # Checklists
    resources :checklists, shallow: true do
      resources :checklist_items,
        only: [:create, :update, :destroy]
    end

  end

  # ==========================================
  # FEED TÉCNICO
  # ==========================================

  resources :post_tecnicos do
    resources :comentarios,
      only: [:create, :destroy]

    resources :curtidas,
      only: [:create, :destroy]
  end

  # ==========================================
  # ADMINISTRAÇÃO
  # ==========================================

  namespace :admin do
    resources :users

    get "/",
      to: "users#index",
      as: :root
  end

  # ==========================================
  # ESTOQUE
  # ==========================================

  namespace :estoque do

    root "home#index"

    # Garantias
    get "garantias",
      to: "garantias#index",
      as: :garantias

    # Produtos
    resources :produtos do
      member do
        get :qr
      end
    end

    # Locais
    resources :locais do
      member do
        get :qr
      end
    end

    # Itens
    resources :itens

    # Saldos
    resources :saldos, only: [:index] do
      collection do
        get :consulta
      end
    end

    # Movimentações
    resources :movimentacoes,
      only: [:index, :show, :new, :create]

    # Recebimentos
    resources :recebimentos, only: [:show] do
      member do
        patch :confirmar
        patch :recusar
      end
    end

    # Recebimentos por local
    get "locais/:local_id/recebimentos",
      to: "recebimentos#index",
      as: :local_recebimentos

    # Notificações de transferências
    get "notificacoes/transferencias_pendentes",
      to: "notificacoes#transferencias_pendentes",
      as: :notificacoes_transferencias_pendentes

    # Scanner
    get "scanner",
      to: "scanner#index",
      as: :scanner

    get "scanner/produto/:qr_token",
      to: "scanner#produto",
      as: :scan_produto

    get "scanner/local/:qr_token",
      to: "scanner#local",
      as: :scan_local

  end

  # ==========================================
  # HEALTH CHECK
  # ==========================================

  get "up" => "rails/health#show",
    as: :rails_health_check

  # ==========================================
  # API V1
  # ==========================================

  namespace :api do
    namespace :v1 do

      resources :condominios,
        only: [:index, :show]

      resources :equipamentos,
        only: [:index, :show]

      resources :historico_tecnicos,
        only: [:index, :show, :create]

      resources :checklists,
        only: [:index, :show, :update]

      resources :post_tecnicos,
        only: [:index, :show, :create]

    end
  end

end
