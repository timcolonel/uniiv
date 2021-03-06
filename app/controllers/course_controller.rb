class CourseController < ApplicationController
  before_action :setup

  def setup
    authorize! :read, Course::Course
  end

  def show
    @course = Course::Course.find(params[:id])
    render :layout => false if request.xhr?
  end

  def json
    course = Course::Course.find(params[:id])
    render :json => course.as_json
  end

  def search_list
    params[:need_reload] ||= false
    @courses = search_course
    render :layout => false
  end

  def search_json
    courses = search_course
    render :json => courses.to_json
  end

  def search_autocomplete
    courses = search_course
    json = {}
    json[:query] = params[:q]
    suggestions = []
    json[:suggestions] = suggestions
    courses.each do |course|
      suggestion = {}
      suggestion[:value] = course.to_s + ' ' + course.name
      suggestion[:data] = course.id
      suggestions << suggestion
    end
    render :json => json.to_json
  end

  def search_course
    limit = params[:limit]
    query = params[:q]
    prerequisites = false
    if query.downcase.start_with?('pre:')
      query = query[4..-1]
      prerequisites = true
    end
    search = Course::Course.search do
      fulltext query
      paginate(:page => 1, :per_page => limit) unless limit.nil?
      without(:course_scenario_ids, current_scenario.id) if params[:only_not_taking]
      with(:course_scenario_ids, current_scenario.id) if params[:only_taking]
      without(:user_ids, current_user.id) if params[:only_not_completed]
      with(:user_ids, current_user.id) if params[:only_completed]
    end
    if prerequisites
      search.results.first.list_dependencies(include_corequisite: false)
    else
      search.results
    end
  end
end