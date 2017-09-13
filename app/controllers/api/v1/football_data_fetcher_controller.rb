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
    if teams.nil?
      return []
    end
    teams
  end

  def fixtures(id)
    result = self.class.get("/competitions/#{id}/fixtures", @options)
    fixtures = JSON.parse(result.body)["fixtures"]
    if fixtures.nil?
      return []
    end
    fixtures
  end

  def predictions(competition)
    # competition = Competition.find(competitionId)
    predictions = Fixture.select{|fixture| fixture.competition_id == competition.id}.map do |fixture|
      if fixture.status == "FINISHED"
        fixture = predict_fixture(fixture, competition)
      else
        # fixture = predict_fixture(fixture, competition)

        # {fixture:fixture, predictions: fixture.predictions}
      end
    end
    # render json: predictions
  end

  def predict_fixture(fixture, competition)
    # breaks here if fixture doesn't have associated team
    if fixture.home_team.nil? || fixture.away_team.nil?
      fixture.goals_home = 0
      fixture.goals_away = 0
      return fixture
    end
    home_outcomes = fixture.home_team.build_outcomes(fixture, competition)
    away_outcomes = fixture.away_team.build_outcomes(fixture, competition)
    if fixture.status != "FINISHED"
      fixture.goals_home = most_likely_outcome(home_outcomes)
      fixture.goals_away = most_likely_outcome(away_outcomes)
    end
    # fixture.predictions = {homeGoals: home_outcomes, awayGoals: away_outcomes}
    Prediction.create(fixture_id: fixture.id, home_goals_0: home_outcomes[0], home_goals_1: home_outcomes[1], home_goals_2: home_outcomes[2], home_goals_3: home_outcomes[3], home_goals_4: home_outcomes[4], home_goals_5: home_outcomes[5], away_goals_0: away_outcomes[0], away_goals_1: away_outcomes[1], away_goals_2: away_outcomes[2], away_goals_3: away_outcomes[3], away_goals_4: away_outcomes[4], away_goals_5: away_outcomes[5])
    fixture.save
  end

  def fetch_predictions_by_competition()
    competition_predictions = Prediction.select{|p| p.fixture.competition_id == params[:id].to_i}
    render json: competition_predictions
  end

  def fetch_fixtures_by_competition(id)
    
    # .select{|f| f.competition_id == id}

    competition_fixtures = Fixture.where("competition_id = #{id}").order('match_day, match_date')
    match_days = []
    matches = []
    last_match = -1
    competition_fixtures.map do |fixture|
      # fixture.send("home_crest_url=", fixture.home_team.crest_url)
      # fixture['away_crest_url'] = fixture.away_team.crest_url
      # fixture.home_crest_url = fixture.home_team.crest_url
      # fixture.away_crest_url = fixture.away_team.crest_url
      if last_match != fixture.match_day
        last_match = fixture.match_day
        if matches.count != 0 
          match_days.push(matches)
          matches = []
        end
      end
      matches.push({data: fixture, home_team: fixture.home_team, away_team: fixture.away_team})
    end
     if matches.count != 0 
        match_days.push(matches)
    end
    match_days
  end

  def get_fixtures_by_competition
    id = params[:id].to_i
    render json: fetch_fixtures_by_competition(id)
  end

  def fetch_fixture()
    fixture = Fixture.find(params[:id].to_i)
    
  if fixture.predictions.count > 0 
    predictions = [] 
    (0..5).each do |home_goal|
      (0..5).each do |away_goal|
        probability = fixture.predictions.first["home_goals_#{home_goal}"] * fixture.predictions.first["away_goals_#{away_goal}"]
        prediction = {home_goals: home_goal, away_goals: away_goal, probability: probability}
        predictions.push(prediction)
      end
    end
    # predictions.sort_by!{|prediction| prediction["probability"]}
    predictions = predictions.sort {|a, b| a[:probability] <=> b[:probability]}
    predictions = predictions.reverse.first(6)
  else 
    predictions = []
  end
    render json: {data: fixture, predictions: predictions, home_team: fixture.home_team, away_team: fixture.away_team, full_predictions: fixture.predictions.first }
  end

  def get_fixtures_by_team
    team_id = params[:id]
    team_fixtures = Fixture.where("home_team_id = #{team_id} or away_team_id = #{team_id}").order('competition_id, match_day, match_date')
    fixtures = team_fixtures.map do |fixture|
      fixture = {data: fixture, home_team: fixture.home_team, away_team: fixture.away_team, competition: fixture.competition}
    end
    render json: fixtures
  end

  def get_teams_by_competition
    all_teams_by_competition = Competition.all.map do |comp|
      {competition: comp, teams: comp.teams}
    end
    render json: all_teams_by_competition
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
    TeamCompetition.destroy_all
    Competition.all.each do |comp|
      teams_list = teams(comp.id)
      teams_list.each do |team|
        new_team = Team.find_or_create_by(id: team["_links"]["self"]["href"].split('/').last)
        new_team.name = team["name"]
        new_team.crest_url = team["crestUrl"]
        new_team.short_name = team["shortName"]
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
        match_date = fixture["date"]
        match_day = fixture["matchday"]
        new_fixture = Fixture.create(home_team_id: home_id, away_team_id: away_id, goals_home: goals_home, goals_away: goals_away, status: status, competition_id: comp.id, match_date: match_date, match_day: match_day)
      end
    end
  end

  def most_likely_outcome(outcomes)
    outcomes.index(outcomes.sort.last)
  end

  def team_data_from_db
    team_data = Team.find(params[:id])
    render json: team_data
  end

  def get_all_teams
    render json: Team.all
  end

  def competition_data_from_db
    competition_data = Competition.find(params[:id])
    render json: competition_data
  end

  def competitions_data_from_db
    allCompetitions = Competition.all
    render json: allCompetitions
  end

  def build_predictions
    Competition.all.each{|comp| predictions(comp)}
  end

end







