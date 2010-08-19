class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string  :name, :limit=>50, :null => false
      t.string  :role
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
