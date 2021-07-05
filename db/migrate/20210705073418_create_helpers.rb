class CreateHelpers < ActiveRecord::Migration[6.0]
  def change
    create_table :helpers do |t|
      t.string :name
      t.string :specialty
      t.string :address
      t.string :number
      t.float :lat
      t.float :lng
    end
  end
end
