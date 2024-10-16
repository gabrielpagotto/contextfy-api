class Context < ApplicationRecord
  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  belongs_to :user
end