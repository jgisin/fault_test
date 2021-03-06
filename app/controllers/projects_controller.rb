class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :confirm_logged_in
  before_action :get_user

  # GET /projects
  # GET /projects.json
  def index
    @projects = @user.projects.sorted
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new({:user_id => @user.id})
    @project_count = Project.count + 1
  end

  # GET /projects/1/edit
  def edit
    @project_count = Project.count
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project_count = Project.count

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    flash[:notice] = "Project '#{@project.name}' has been destroyed successfully"
    redirect_to(:action => 'index', :user_id => @project.user_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :notes, :user_id, :init_fault)
    end
end
