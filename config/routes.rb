Rails.application.routes.draw do
  root "projects#index"

  resources :projects do
    resources :team_members, only: %i[new create edit update destroy]
    resources :milestones, only: %i[new create edit update destroy]
  end
end
