class CreateFixtures < ActiveRecord::Migration[5.1]
  def change
    create_table :fixtures do |t|
    	t.integer :home_team_id
    	t.integer :away_team_id
    	t.integer :goals_home
    	t.integer :goals_away
    	t.string :status
    	t.integer :competition_id
      t.timestamps
    end
  end
end
