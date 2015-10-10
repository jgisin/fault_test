class CreatePanels < ActiveRecord::Migration
  def change
    create_table :panels do |t|
      #Panel Variables
      t.string :panel_name
      t.integer :position
      t.float :wire_length
      t.float :init_fault
      t.float :runs
      t.float :voltage
      t.float :c_value
      t.integer :wire_type
      t.integer :conduit_type
      t.integer :run_type
      #Result Variables
      t.float :f_value
      t.float :m_value
      t.float :final_value
      #Foreign Key
      t.integer :project_id


      t.timestamps null: false
    end



  end
end
