class Todo < ApplicationRecord
  validates :task, presence: true
  validates :description, presence: true
end
