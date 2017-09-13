class Fixture < ApplicationRecord
	belongs_to :competition
	belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
	belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'
	has_many :predictions

	attr_accessor :home_crest_url, :away_crest_url

	def self.refresh


	end
end
