class Program::VersionController < ApplicationController

  before_action :setup

  def setup
    @program = Program::Program.find(params[:program_id])
  end

  def new
    authorize! :new, Program::Version
    @program_version = Program::Version.new
  end

  def create
    authorize! :create, Program::Version
    template = Program::Version.find_by_id(params[:template])
    @program_version = if template.nil?
                         Program::Version.new
                       else
                         template.new_copy
                       end
    @program_version.assign_attributes(version_params)
    @program_version.program = @program
    if @program_version.save
      redirect_to program_path(@program)
    else
      render :new
    end
  end

  def edit
    authorize! :edit, Program::Version
    @program_version = Program::Version.find(params[:id])
  end

  def update
    authorize! :update, Program::Version
    @program_version = Program::Version.find(params[:id])
    @program_version.assign_attributes(version_params)
    if @program_version.save
      redirect_to program_path(@program)
    else
      render :edit
    end
  end

  def show

  end
  
  def list
  end

  def version_params
    params.require(:program_version).permit(:start_year, :end_year)
  end
end
