class Physician < ApplicationRecord
  validates :name, :specialty, :address, :number, presence: true
end
