class Helper < ApplicationRecord
  validates :name, :specialty, :address, :number, presence: true
end
