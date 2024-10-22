class RatedTrack < ApplicationRecord
  validates :sptf_track_id, presence: true
  validates :rate, presence: true
  validates :user_id, presence: true
  validates :context_id, presence: true

  belongs_to :user
  belongs_to :context
end
