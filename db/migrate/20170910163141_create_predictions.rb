class CreatePredictions < ActiveRecord::Migration[5.1]
  def change
    create_table :predictions do |t|
    	t.integer :fixture_id
    	t.float :home_goals_0
    	t.float :home_goals_1
    	t.float :home_goals_2
    	t.float :home_goals_3
    	t.float :home_goals_4
    	t.float :home_goals_5
      	t.float :away_goals_0
    	t.float :away_goals_1
    	t.float :away_goals_2
    	t.float :away_goals_3
    	t.float :away_goals_4
    	t.float :away_goals_5
      t.timestamps
    end
  end
end
