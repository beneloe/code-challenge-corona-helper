class CreateCounsellors < ActiveRecord::Migration[6.0]
  def change
    create_table :counsellors do |t|
      t.string :name
      t.string :specialty
      t.string :address
      t.integer :number
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
