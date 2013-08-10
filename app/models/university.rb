class University < ActiveRecord::Base
  belongs_to :grading_system, :class_name => Course::GradingSystem
  has_many :faculties, :class_name => Faculty

  def to_s
    name
  end
end
