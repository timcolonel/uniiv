class Course::Scenario < ActiveRecord::Base
  belongs_to :user, :class_name => User
  has_many :taking_courses, :class_name => UserTakingCourse, :foreign_key => 'course_scenario_id', :dependent => :destroy
  has_many :courses, :through => :taking_courses

  has_and_belongs_to_many :programs, -> { uniq }, :class_name => 'Program::Version'

  validate do
    errors.add(:program, t('error.program.maximum')) if reached_max_programs?
  end

  def has_completed_course?(course, inc_advanced_standing = true, term = nil)
    if term.nil?
      user.has_completed_course?(course, inc_advanced_standing)
    else
      user.has_completed_course?(course, inc_advanced_standing) or will_course_be_completed(course, term)
    end
  end

  #Return if the scenario is taking this course at the given semester(default is the current one)
  def is_taking_course?(course, term = nil)
    term ||= Utils::Term::now
    taking_courses.each do |c|
      if c.course == course and c.year == term.year and c.semester == term.semester
        return true
      end
    end
    false
  end

  #Return if the user planned to take this course in any term
  def plan_to_take_course?(course)
    taking_courses.where(:course_id => course).size >0
  end

  def requirements_completed?(course, term = nil)
    course.requirements_completed?(self, term)
  end

  #Return if the user is taking courses at the wrong time
  def has_errors?
    taking_courses.each do |course|
      unless course.is_time_valid?
        return true
      end
    end
    false
  end

  #Check if a course is going to be completed in the given term
  def will_course_be_completed(course, term)
    taking_course = taking_courses.where(:course_id => course).first
    if taking_course.nil?
      false
    else
      taking_course.year < term.year or (taking_course.year <= term.year and taking_course.semester.order < term.semester.order)
    end
  end

  def get_by_course(course)
    taking_courses.where(:course_id => course).first
  end


  def get_course_in_semester(semester, year)
    taking_courses.where(:semester_id => semester, :year => year)
  end

  def get_course_later_than(semester, year)
    taking_courses.joins(:semester).where('(course_semesters.order > :order AND year = :year) OR year > :year',
                                          :order => semester.order, :year => year)
  end

  def get_course_before_than(semester, year)
    taking_courses.joins(:semester).where('(course_semesters.order < :order and year = :year) or year < :year', :order => semester.order, :year => year)
  end

  #Check if the scenario is taking the course
  def is_taking?(course)
    courses.include?(course)
  end

  def get_course_recommendations

  end

  def get_courses_in_programs(filters={})
    default_options={
        scenario_id: self.id,
        only_taking: false,
        only_not_taking: false,
        only_completed: false,
        only_not_completed: false
    }
    filters = filters.reverse_merge(default_options)
    filters[:program] ||= programs.map { |x| x.id }
    Course::CourseSearcher.search(filters)
  end

  #Take the given course at the given semester
  #If user is already taking the course update it
  def take_course(course, term)
    user_taking_course = taking_courses.where(:course_id => course.id).first
    if user_taking_course.nil?
      user_taking_course = UserTakingCourse.new
      user_taking_course.course_scenario = self
      user_taking_course.course = course
    end
    user_taking_course.semester = term.semester
    user_taking_course.year = term.year
    if user_taking_course.save
      user_taking_course
    else
      self.errors.add(:taking_courses, user_taking_course.errors.full_messages)
      nil
    end
  end


  def complete_course(course, term = nil)
    user.complete_course(course, term)
  end

  def untake_course(course, skip_completed = false)
    user_taking_course = taking_courses.where(:course_id => course).first
    user_taking_course.destroy unless user_taking_course.nil?
    user.uncomplete_course(course) unless skip_completed
  end

  def reached_max_programs?
    programs.size > 6
  end

  def to_s
    "#{user.to_s} (#{id.to_s})"
  end

  alias :can_take_course? :requirements_completed?
end
