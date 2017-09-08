class Team < ApplicationRecord
	has_many :home_games, foreign_key: "home_team_id", class_name: "Fixture"
	has_many :away_games, foreign_key: "away_team_id", class_name: "Fixture"

	def build_outcomes(competitionId)
    	(0..5).map{ |i| team.probability_of(i, competitionId)}
  	end

  	def probability_of(goals, competitionId)

  	end

  	def played_home_games(competitionId)
  		home_games.select{|game| competitionId == game.competition.id && game.status == "FINISHED"}
  	end

  	def played_away_games(competitionId)
  		away_games.select{|game| competitionId == game.competition.id && game.status == "FINISHED"}
  	end

  	def home_attack_strength(competitionId)
  		home_games_competition = played_home_games(competitionId)
  		total_goals_home = home_games_competition.inject(0) { |sum, game| sum + game.goals_home}
  		average_home_goals = if home_games_competition.count != 0
  			total_goals_home / home_games_competition.count 
  		else
  			0
  		end
  		attack_strength = if Competition.find_by(id: competitionId).home_goal_average != 0
  			average_home_goals / Competition.find_by(id: competitionId).home_goal_average 
  		else 
  			0
  		end
  	end

  	def away_attack_strength(competitionId)
   		away_games_competition = played_away_games(competitionId)
  		total_goals_away = away_games_competition.inject(0) { |sum, game| sum + game.goals_away}
  		average_away_goals = if away_games_competition.count != 0
  			total_goals_away / away_games_competition.count
  		else
  			0
  		end
  		attack_strength = if Competition.find_by(id: competitionId).away_goal_average != 0
  			average_away_goals / Competition.find_by(id: competitionId).away_goal_average
  		else
  			0
  		end
  	end

  	def home_defense_strength(competitionId)
  		home_games_competition = played_home_games(competitionId)
  		conceeded_home = home_games_competition.inject(0) { |sum, game| sum + game.goals_away}
  		average_conceeded = if home_games_competition.count != 0 
  			conceeded_home / home_games_competition.count
  		else
  			0
  		end
  		defense_strength = if Competition.find_by(id: competitionId).away_goal_average != 0
  			average_conceeded / Competition.find_by(id: competitionId).away_goal_average
  		else 
  			0
  		end
  	end

  	def away_defense_strength(competitionId)
		away_games_competition = played_away_games(competitionId)
  		conceeded_away = away_games_competition.inject(0) { |sum, game| sum + game.goals_home}
  		average_conceeded = if away_games_competition.count != 0 
  			conceeded_away / away_games_competition.count
  		else
  			0
  		end
  		defense_strength = if Competition.find_by(id: competitionId).home_goal_average != 0
  			average_conceeded / Competition.find_by(id: competitionId).home_goal_average
  		else
  			0
  		end
  	end

end
