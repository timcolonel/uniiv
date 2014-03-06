class UserCompletedCourse < ActiveRecord::Base
  belongs_to :user, :class_name => User
  belongs_to :course, :class_name => Course::Course
  belongs_to :grade, :class_name => Course::GradingSystemEntity
  belongs_to :semester, :class_name => Course::Semester

  validates_presence_of :course_id
  validates_presence_of :user_id
  validates_presence_of :grade_id
  validates_presence_of :semester_id
  validates_presence_of :year
  validates_uniqueness_of :course_id, :scope => :user_id

  after_validation :remove_course_taking, on: [:create, :update]

  after_save :reindex
  after_destroy :reindex

  def to_s
    user.to_s + ' - ' + course.to_s
  end

  def reindex
    course.index unless course.nil?
  end

  #Remove this course if the user is taking it in any scenarios
  def remove_course_taking
    c_id = course_id
    UserTakingCourse.joins(:course_scenario).where { course_scenario.user.id == user_id && course_id==c_id }.readonly(false).destroy_all
  end

end
