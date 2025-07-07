Rails.application.routes.draw do
  # Devise routes (회원가입 비활성화)
  devise_for :users, skip: [:registrations]
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"
  
  resources :posts do
    collection do
      get :study
      get :planning
      get :development
      get :milestones
    end
  end
  
  # 관리자 전용 (윤두철 변호사)
  namespace :admin do
    resources :users, only: [:index, :edit, :update] do
      member do
        post :reset_password
      end
    end
  end
end
