class CreateTeamCompetitions < ActiveRecord::Migration[5.1]
  def change
    create_table :team_competitions do |t|
    	t.integer :team_id
    	t.integer :competition_id
      t.timestamps
    end
  end
end
