class CreatePanels < ActiveRecord::Migration
  def change
    create_table :panels do |t|
      t.float :wire_length
      t.float :init_fault
      t.float :runs
      t.float :voltage
      t.float :c_value

      t.timestamps null: false
    end
  end
end
