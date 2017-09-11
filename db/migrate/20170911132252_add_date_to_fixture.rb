class AddDateToFixture < ActiveRecord::Migration[5.1]
  def change
  	add_column :fixtures, :match_date, :datetime
  	add_column :fixtures, :match_day, :integer
  end
end
