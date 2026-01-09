class Task < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  scope :ordered, -> { order(position: :asc) }
end
