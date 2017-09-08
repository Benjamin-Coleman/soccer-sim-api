class Api::V1::FootballDataFetcherController < ApplicationController
  include HTTParty
  base_uri 'http://api.football-data.org/v1/'

  def create
    
  end


  def initialize()
    @options =  {
      headers:{
            'X-Auth-Token': '322fbe367f614460b8a20fa21503767e'
        }, 
        dataType: 'json',
        type: 'GET'
      } 
  end

  def competitions
    result = self.class.get("/competitions", @options)
    competitions = JSON.parse(result.body)
    render json: competitions
    competitions
  end

  def teams(id)
    result = self.class.get("/competitions/#{id}/teams", @options)
    teams = JSON.parse(result.body)["teams"]
    teams
  end

  def fixtures(id)
    result = self.class.get("/competitions/#{id}/fixtures", @options)
    fixtures = JSON.parse(result.body)["fixtures"]
    fixtures
  end

  def predictions
    result = self.class.get("/competitions/#{params['id']}/fixtures")
    fixtures = JSON.parse(result.body)['fixtures']
    predictions = predictions_method(fixtures)

    render json: predictions
  end

  def predictions_method(fixtures)
    build_teams(fixtures)
    fixtures.map do |fixture|
      if fixture['status'] == "FINISHED"
        fixture
      else
        predict_fixture(fixture)
      end
    end
  end

  def predict_fixture(fixture)
    home_outcomes = build_outcomes(fixture["homeTeamId"])
    away_outcomes = build_outcomes(fixture["awayTeamId"])
    fixture["result"]["goalsHomeTeam"] = most_likely_outcome(home_outcomes)
    fixture["result"]["goalsAwayTeam"] = most_likely_outcome(away_outcomes)
    fixture["predictions"] = {homeGoals: home_outcomes, awayGoals: away_outcomes}
    fixture
  end

  # def build_teams(fixtures)
  #   fixtures.each do |fixture|
  #     if fixture['status'] == "FINISHED"
  #       home_team = Team.findOrCreate(fixture["homeTeamId"])
  #       home_team.add_goals_home(fixture["result"]["goalsHomeTeam"])
  #       away_team = Team.findOrCreate(fixture["awayTeamId"])
  #       away_team.add_goals_away(fixture["result"]["goalsAwayTeam"])
  #     end
  #   end    
  # end

  def builds_competitions
    competitions.each do |competition|
      Competition.create(id: competition["id"], name: competition["caption"])
    end
  end

  def build_teams
    Competition.all.each do |comp|
      teams(comp.id).each do |team|
        new_team = Team.find_or_create_by(id: team["_links"]["self"]["href"].split('/').last)
        new_team.name = team["name"]
        new_team.save
        TeamCompetition.create(team_id: new_team.id, competition_id: comp.id)
      end
    end
  end

  def build_fixtures
    Competition.all.each do |comp|
      fixtures(comp.id).each do |fixture|
        home_id = fixture["_links"]["homeTeam"]["href"].split('/').last 
        away_id = fixture["_links"]["awayTeam"]["href"].split('/').last 
        goals_home = fixture["result"]["goalsHomeTeam"]
        goals_away = fixture["result"]["goalsAwayTeam"]
        status = fixture["status"]
        new_fixture = Fixture.create(home_team_id: home_id, away_team_id: away_id, goals_home: goals_home, goals_away: goals_away, status: status, competition_id: comp.id)
      end
    end
  end

  def build_outcomes(teamId)
    team = Team.findOrCreate(teamId)
    (0..5).map{ |i| team.probability_of(i)}
  end

  def most_likely_outcome(outcomes)
    outcomes.sort.last
  end

end







