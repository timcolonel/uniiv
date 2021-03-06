class UserDashboardController < ApplicationController
  def index
    authorize! :view, current_user

    @university = current_user.university
    @faculty = current_user.faculty
    @programs = current_user.main_course_scenario.programs
    @fullwidth = true
    if current_scenario.programs.empty?
      redirect_to user_education_selection_path
    end
  end

  def selection
    authorize! :view, current_user
  end

  def user_course_taking_content
    authorize! :view, current_user
    render :partial => 'course_taking', :layout => false
  end

  def user_course_completed_content
    authorize! :view, current_user
    render :partial => 'course_completed', :layout => false
  end
end
