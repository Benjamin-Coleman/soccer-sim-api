require 'poisson'

class Team < ApplicationRecord
	has_many :home_games, foreign_key: "home_team_id", class_name: "Fixture"
	has_many :away_games, foreign_key: "away_team_id", class_name: "Fixture"
  has_many :team_competitions
  has_many :competitions, through: :team_competitions

	def build_outcomes(fixture, competition)
		fixture_competition = competition
		completed_home_games = home_games.select{|game| fixture_competition == game.competition && game.status == "FINISHED"}
		completed_away_games = away_games.select{|game| fixture_competition == game.competition && game.status == "FINISHED"}

		if self == fixture.home_team
			attack_strength = home_attack_strength(fixture_competition, completed_home_games)
			defense_strength = fixture.away_team.away_defense_strength(fixture_competition, completed_home_games)
			goal_average = fixture_competition.home_goal_average
		else
			attack_strength = away_attack_strength(fixture_competition, completed_away_games)
			defense_strength = fixture.home_team.home_defense_strength(fixture_competition, completed_away_games)
			goal_average = fixture_competition.away_goal_average
		end

    	(0..5).map{ |i| self.probability_of(i, attack_strength, defense_strength, goal_average)}
  	end

  	def probability_of(goals, attack_strength, defense_strength, goal_average)
		goal_probability = attack_strength * defense_strength * goal_average
  		poisson = Poisson.new(goal_probability)
		poisson.probability { |x| x == goals }
  	end

  	def played_home_games(competitionId)
  		home_games.select{|game| competitionId == game.competition.id && game.status == "FINISHED"}
  	end

  	def played_away_games(competitionId)
  		away_games.select{|game| competitionId == game.competition.id && game.status == "FINISHED"}
  	end

  	def home_attack_strength(competition, completed_home_games)
  		# home_games_competition = played_home_games(competitionId)
  		total_goals_home = completed_home_games.inject(0) { |sum, game| sum + game.goals_home}
  		average_home_goals = if completed_home_games.count != 0
  			total_goals_home.to_f / completed_home_games.count 
  		else
  			0
  		end
  		attack_strength = if competition.home_goal_average != 0
  			average_home_goals / competition.home_goal_average 
  		else 
  			0
  		end
  	end

  	def away_attack_strength(competition, completed_away_games)
   		# away_games_competition = played_away_games(competitionId)
  		total_goals_away = completed_away_games.inject(0) { |sum, game| sum + game.goals_away}
  		average_away_goals = if completed_away_games.count != 0
  			total_goals_away.to_f / completed_away_games.count
  		else
  			0
  		end
  		attack_strength = if competition.away_goal_average != 0
  			average_away_goals / competition.away_goal_average
  		else
  			0
  		end
  	end

  	def home_defense_strength(competition, completed_home_games)
  		# home_games_competition = played_home_games(competitionId)
  		conceeded_home = completed_home_games.inject(0) { |sum, game| sum + game.goals_away}
  		average_conceeded = if completed_home_games.count != 0 
  			conceeded_home.to_f / completed_home_games.count
  		else
  			0
  		end
  		defense_strength = if competition.away_goal_average != 0
  			average_conceeded/ competition.away_goal_average
  		else 
  			0
  		end
  	end

  	def away_defense_strength(competition, completed_away_games)
		# away_games_competition = played_away_games(competitionId)
  		conceeded_away = completed_away_games.inject(0) { |sum, game| sum + game.goals_home}
  		average_conceeded = if completed_away_games.count != 0 
  			conceeded_away.to_f / completed_away_games.count
  		else
  			0
  		end
  		defense_strength = if competition.home_goal_average != 0
  			average_conceeded / competition.home_goal_average
  		else
  			0
  		end
  	end

end
