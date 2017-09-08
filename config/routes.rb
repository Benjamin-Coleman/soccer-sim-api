Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/competitions', to: 'football_data_fetcher#competitions'
      get '/competitions/:id/predictions/', to: 'football_data_fetcher#predictions'
      get '/competitions/seed', to: 'football_data_fetcher#builds_competitions'
      get '/teams/seed', to: 'football_data_fetcher#build_teams'
      get '/fixtures/seed', to: 'football_data_fetcher#build_fixtures'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end