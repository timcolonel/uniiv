class User < ActiveRecord::Base

  belongs_to :university, :class_name => University
  belongs_to :faculty, :class_name => Faculty

  has_many :emails, :class_name => UserEmail, :dependent => :destroy

  has_and_belongs_to_many :roles

  #has_many :taking_courses, :class_name => UserTakingCourse
  has_many :completed_courses, :class_name => UserCompletedCourse, :dependent => :destroy

  has_many :course_reviews, :class_name => Course::Review

  has_many :course_scenarios, :class_name => Course::Scenario, :dependent => :destroy
  has_one :main_course_scenario, -> { where :main => true }, :class_name => Course::Scenario

  has_many :course_recommendations, :class_name => UsersCoursesRecommendation, :dependent => :destroy

  has_many :fgc_predictions, :class_name => Fgc::Prediction

  #Validations
  validates :advanced_standing_credits, :presence => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (email = conditions[:email])
      User.includes(:emails).where('user_emails.email = ?', email).first
    else
      where(conditions).first
    end
  end

  def role?(role)
    !!self.roles.find_by_name(role.to_s.camelize)
  end


  def permitted_params
    params.permit!
  end

  def total_completed_ratio
    ratio = 0
    coef = 0
    self.main_course_scenario.programs.each do |p|
      hash = p.get_completion_ratio(main_course_scenario)
      ratio += hash[:value]
      coef += hash[:coefficient]
    end
    ratio / coef
  end

  def has_completed_course?(course, inc_advanced_standing = true)
    if inc_advanced_standing
      completed_courses.where(:course_id => course.id).size > 0
    else
      completed_courses.where(:course_id => course.id, :advanced_standing => false).size > 0
    end
  end

  def is_taking_course?(course)
    main_course_scenario.taking_courses.where(:course_id => course.id).size > 0
  end

  def has_completed_or_taking_course?(course)
    has_completed_course?(course) or is_taking_course?(course)
  end


  def count_completed_credit
    count = 0
    completed_courses.each do |c|
      count += c.course.credit unless c.advanced_standing
    end
    count += advanced_standing_credits
  end

  def count_taking_credit
    count = 0
    main_course_scenario.taking_courses.each do |c|
      count += c.credit
    end
    count
  end

  def reviewed_course?(course)
    course_reviews.where(:course_id => course).any?
  end

  def count_completed_credit_after_taking
    count_completed_credit + count_taking_credit
  end

  def requirements_completed?(course, scenario = nil)
    scenario ||= main_course_scenario
    scenario.requirements_completed?(course)
  end

  def requirements_completed_after_taking?(course)
    course.requirements_completed_after_taking?(self, true)
  end


  def get_recommended_courses

  end

  #Return the show of the latest edited final grade calculator courses
  def get_last_fgc_courses(limit = 5)
    fgc_predictions.order(:updated_at => :desc).limit(limit)
  end

  #Complete a course, term can be nil if the course was already taking
  #Will remove the course from the scenario in which the user is taking it
  def complete_course(course, grade, term = nil)
    user_completed_course = completed_courses.where(:course => course).first
    if user_completed_course.nil?
      course_scenarios.each do |scenario|
        taking_course = scenario.taking_courses.where(:course_id => course.id).first
        unless taking_course.nil?
          term ||= taking_course.term
          taking_course.destroy
        end
      end
      user_completed_course = UserCompletedCourse.new
      user_completed_course.course = course
      user_completed_course.user = self
    end
    user_completed_course.term = term
    user_completed_course.grade= grade
    if user_completed_course.save
      true
    else
      self.errors.add :completed_courses, user_completed_course.errors.full_messages
      false
    end
  end

  #Will reset everything the user is taking
  def reset
    course_scenarios.destroy_all
    scenario= Course::Scenario.new
    scenario.main = true
    course_scenarios << scenario
    completed_courses.destroy_all
  end

  def to_s
    email
  end

  alias :can_take_course? :requirements_completed?
end
