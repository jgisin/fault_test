class CreatePanels < ActiveRecord::Migration
  def change
    create_table :panels do |t|
      t.string :panel_name
      t.float :wire_length
      t.float :init_fault
      t.float :runs
      t.float :voltage
      t.float :c_value
      t.float :f_value
      t.float :m_value
      t.float :final_value

      t.timestamps null: false
    end
  end
end
