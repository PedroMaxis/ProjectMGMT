Rails.application.routes.draw do
  root "dashboard#show"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  post "login/demo/:id", to: "sessions#demo", as: :demo_login
  delete "logout", to: "sessions#destroy"

  resources :users, only: %i[index show update]

  resources :products do
    resources :releases, only: %i[create update destroy]
    resources :pages, only: %i[new create]
  end

  resources :projects, param: :key do
    member do
      get :board
      get :backlog
      get :timeline
      get :reports
    end
    resources :sprints, only: %i[create update destroy] do
      member do
        post :start
        post :complete
      end
    end
    resources :milestones, only: %i[create update destroy]
    resources :memberships, only: %i[create destroy]
    resources :issues, only: %i[new create]
    resources :pages, only: %i[new create]
  end

  resources :issues, param: :key, only: %i[show update destroy] do
    member { patch :move }
    resources :comments, only: %i[create destroy]
  end

  resources :pages, only: %i[show edit update destroy]

  get "roadmap", to: "roadmap#show"
  get "search", to: "search#index"
  post "markdown", to: "markdown#create", as: :markdown_preview

  get "up" => "rails/health#show", as: :rails_health_check
end
