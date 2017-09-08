class Competition < ApplicationRecord
	has_many :fixtures

	def home_goal_average
		played_games = self.fixtures.select{ |fixture| fixture.status == "FINISHED" }
		total = played_games.inject(0) { |sum, fixture|
			sum + fixture.goals_home
		}
		if played_games.length != 0 && total != 0
			total.to_f / played_games.length.to_f
		else
			0
		end
	end

	def away_goal_average
		played_games = self.fixtures.select{ |fixture| fixture.status == "FINISHED" }
		total = played_games.inject(0) { |sum, fixture|
			sum + fixture.goals_away
		}
		if played_games.length != 0 && total != 0
			total.to_f / played_games.length.to_f
		else
			0
		end
	end
end
