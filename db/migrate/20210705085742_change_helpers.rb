class ChangeHelpers < ActiveRecord::Migration[6.0]
  def change
    rename_column :helpers, :lat, :latitude
    rename_column :helpers, :lng, :longitude
  end
end
