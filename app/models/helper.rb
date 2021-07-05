class Helper < ApplicationRecord
  validates :name, :specialty, :address, :number, presence: true
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
