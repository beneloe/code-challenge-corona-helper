class CreatePhysicians < ActiveRecord::Migration[6.0]
  def change
    create_table :physicians do |t|
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
