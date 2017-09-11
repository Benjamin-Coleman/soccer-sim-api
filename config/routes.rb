Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/competitions', to: 'football_data_fetcher#competitions'
      # get '/competitions/:id/predictions/', to: 'football_data_fetcher#predictions'
      get '/competitions/:id/predictions/', to: 'football_data_fetcher#fetch_predictions_by_competition'
      get '/competitions/:id/fixtures/', to: 'football_data_fetcher#fetch_fixtures_by_competition'
      get '/competitions/:id', to: 'football_data_fetcher#competition_data_from_db'
      get '/competitions/seed', to: 'football_data_fetcher#builds_competitions'
      get '/teams/seed', to: 'football_data_fetcher#build_teams'
      get '/fixtures/seed', to: 'football_data_fetcher#build_fixtures'
      get '/teams/:id', to: 'football_data_fetcher#team_data_from_db'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end