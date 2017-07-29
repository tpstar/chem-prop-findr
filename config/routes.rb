Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :chemicals
  end

  get 'api/chemicals/search/*qchemname', :to => 'api/chemicals#search'
  # http://localhost:3000/api/chemicals/search/qchemname
end
