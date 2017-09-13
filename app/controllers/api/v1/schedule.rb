class Api::V1::Schedule < ApplicationController

	def self.fetchAllFixtures		
		football_data_fetcher = Api::V1::FootballDataFetcherController.new
		football_data_fetcher.build_fixtures
		football_data_fetcher.build_predictions
	end
end