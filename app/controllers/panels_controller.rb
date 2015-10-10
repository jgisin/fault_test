class PanelsController < ApplicationController
  before_action :get_project
  before_action :get_user
  before_action :confirm_logged_in
  before_action :set_panel, only: [:show, :edit, :update, :destroy]

  # GET /panels
  # GET /panels.json
  def index
    @panels = @project.panels.sorted
      @panels.each do |panel|
        if panel.voltage == 208 || panel.voltage == 480
          panel.f_value = (1.73 * panel.wire_length * panel.init_fault)/
          (panel.runs * panel.c_value * panel.voltage)
          panel.m_value = 1/(1+panel.f_value)
          panel.final_value = panel.init_fault * panel.m_value
      else
          panel.f_value = (2 * panel.wire_length * panel.init_fault)/
          (panel.runs * panel.c_value * panel.voltage)
          panel.m_value = 1/(1+panel.f_value)
          panel.final_value = panel.init_fault * panel.m_value
      end
    end
  end

  # GET /panels/1
  # GET /panels/1.json
  def show
  end

  # GET /panels/new
  def new
    @panel = Panel.new({:project_id => @project.id})
    @panel_count = Panel.count + 1
  end

  # GET /panels/1/edit
  def edit
    @panel_count = Panel.count
  end

  # POST /panels
  # POST /panels.json
  def create
    @panel = Panel.new(panel_params)
    if @panel.voltage == 208 || @panel.voltage == 480
    panel_calcs(1.73)
  else
    panel_calcs(2)
  end
    respond_to do |format|
      if @panel.save
        format.html { redirect_to @panel, notice: 'Panel was successfully created.'}
        format.json { render :show, status: :created, location: @panel }
      else
        format.html { render :new }
        format.json { render json: @panel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /panels/1
  # PATCH/PUT /panels/1.json
  def update
    respond_to do |format|
      if @panel.voltage == 208 || @panel.voltage == 480
    panel_calcs(1.73)
    else
      panel_calcs(2)
    end
      if @panel.update(panel_params)
        format.html { redirect_to @panel, notice: 'Panel was successfully updated.' }
        format.json { render :show, status: :ok, location: @panel }
      else
        format.html { render :edit }
        format.json { render json: @panel.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
  end
  # DELETE /panels/1
  # DELETE /panels/1.json
  def destroy
    @panel.destroy
    flash[:notice] = "Panel '#{@panel.panel_name}' has been destroyed successfully"
    redirect_to(:action => 'index', :project_id => @panel.project_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_panel
      @panel = Panel.find(params[:id])
    end

    def panel_calcs(var_volt)
    @panel.f_value = (var_volt * @panel.wire_length * @panel.init_fault)/
    (@panel.runs * @panel.c_value * @panel.voltage)
    @panel.m_value = 1/(1+@panel.f_value)
    @panel.final_value = @panel.init_fault * @panel.m_value
    end



    # Never trust parameters from the scary internet, only allow the white list through.
    def panel_params
      params.require(:panel).permit(:wire_length, :init_fault, :runs, :voltage, :c_value, :panel_name,
        :f_value, :m_value, :final_value, :project_id, :position, :wire_type, :conduit_type, :runs_type)
    end
end
