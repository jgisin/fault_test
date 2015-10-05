class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string :name
      t.string :notes

      t.timestamps null: false
    end

      add_foreign_key :panels, :projects
  end

  def down
  	drop_table :projects
  end

end
