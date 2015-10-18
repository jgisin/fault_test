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
      panel.c_value = c_val_picker(panel.wire_size, panel.wire_type, 
      panel.conduit_type, panel.run_type)
      if panel.init_fault == nil || panel.init_fault != @project.init_fault
        panel.init_fault = init_fault_picker(panel.fed_from)
      end
      if panel.final_value != nil
        if panel.voltage == 208 || panel.voltage == 480
          panel.f_value = (1.73 * panel.wire_length * init_fault_picker(panel.fed_from))/
          (panel.runs * panel.c_value * panel.voltage)
          panel.m_value = 1/(1+panel.f_value)
          panel.final_value = panel.init_fault * panel.m_value
        else
          panel.f_value = (2 * panel.wire_length * panel.init_fault)/
          (panel.runs * panel.c_value * panel.voltage)
          panel.m_value = 1/(1+panel.f_value)
          panel.final_value = init_fault_picker(panel.fed_from) * panel.m_value
        end
      end
    end
  end

  # GET /panels/1
  # GET /panels/1.json
  def show
      @panel.init_fault = init_fault_picker(@panel.fed_from)
      @panel.c_value = c_val_picker(@panel.wire_size, @panel.wire_type, 
          @panel.conduit_type, @panel.run_type)
        if @panel.voltage == 208 || @panel.voltage == 480
          panel_calcs(1.73)
        else
          panel_calcs(2)
        end
  end

  # GET /panels/new
  def new
    @panel = Panel.new({:project_id => @project.id})
    @panel_count = Panel.count + 1
    @panel_names = Panel.where(:project_id => @project.id).pluck(:panel_name)
    @panel_names.insert(0, "Transformer")
  end

  # GET /panels/1/edit
  def edit
    @panel_count = Panel.count
    @panel_names = Panel.where(:project_id => @panel.project_id).pluck(:panel_name)
    @panel_names.insert(0, "Transformer")
  end

  # POST /panels
  # POST /panels.json
  def create
    @panel = Panel.new(panel_params)
    @panel_count = Panel.count
     @panel_names = Panel.where(:project_id => @panel.project_id).pluck(:panel_name)
    @panel.c_value = c_val_picker(@panel.wire_size, @panel.wire_type, 
          @panel.conduit_type, @panel.run_type)
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

      if @panel.update(panel_params)
          @panel.c_value = c_val_picker(@panel.wire_size, @panel.wire_type, 
          @panel.conduit_type, @panel.run_type)
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
    Panel.where(:fed_from => @panel.panel_name).destroy(Panel.where(:fed_from => @panel.panel_name).pluck(:id))
    flash[:notice] = "Panel '#{@panel.panel_name}' has been destroyed successfully"
    redirect_to(:action => 'index', :project_id => @panel.project_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_panel
      @panel = Panel.find(params[:id])
    end

    def panel_calcs(var_volt)
      @panel.f_value = (var_volt * @panel.wire_length * init_fault_picker(@panel.fed_from))/
      (@panel.runs * @panel.c_value * @panel.voltage)
      @panel.m_value = 1/(1+@panel.f_value)
      @panel.final_value = init_fault_picker(@panel.fed_from) * @panel.m_value
      @panel.save
    end

    def init_fault_picker(fed_from)
        if fed_from != "Transformer"
          if defined? @project.id
            return Panel.where(:panel_name => fed_from, :project_id => @project.id).pluck(:final_value)[0]
          else
            return Panel.where(:panel_name => fed_from, :project_id => @panel.project_id).pluck(:final_value)[0]
          end
        else
          if defined? @panel
            return Project.where(:id => @panel.project_id).pluck(:init_fault)[0]
          else
            return Project.where(:id => @project.id).pluck(:init_fault)[0]
          end
        end
    end

    def c_val_picker(wire_size, wire_type, conduit_type, runs_type)
      case wire_size
      when "14"
          if wire_type == 1 && conduit_type == 1 && runs_type == 1
            return 389
            elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
              return 389
            elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
              return 389
            elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
              return 389
            elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
              return 237
            elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
              return 237
            elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
              return 237
            elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
              return 237
            end
          when "12"
           if wire_type == 1 && conduit_type == 1 && runs_type == 1
            return 617
          elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
            return 617
          elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
            return 617
          elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
            return 617
          elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
            return 376
          elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
            return 376
          elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
            return 376
          elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
            return 376
          end
        when "10"
         if wire_type == 1 && conduit_type == 1 && runs_type == 1
          return 981
        elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
          return 982
        elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
          return 982
        elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
          return 982
        elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
          return 599
        elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
          return 599
        elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
          return 599
        elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
          return 599
        end
      when "8"
       if wire_type == 1 && conduit_type == 1 && runs_type == 1
        return 1557
      elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
        return 1559
      elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
        return 1559
      elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
        return 1560
      elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
        return 951
      elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
        return 952
      elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
        return 952
      elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
        return 952
      end
    when "6"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 2425
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 2431
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 2430
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 2433
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 1481
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 1482
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 1482
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 1482
    end
    when "4"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 3806
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 3830
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 3826
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 3838
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 2346
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 2351
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 2350
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 2353
    end
    when "3"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 4774
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 4820
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 4811
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 4833
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 2952
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 2963
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 2961
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 2966
    end
    when "2"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 5907
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 5989
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 6044
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 6087
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 3713
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 3734
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 3730
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 3740
    end
    when "1"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 7263
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 7454
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 7493
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 7579
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 4645
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 4686
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 4678
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 4699
    end
    when "1/0"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 8925
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 9210
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 9317
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 9473
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 5777
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 5852
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 5838
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 5876
    end
    when "2/0"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 10755
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 11245
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 11424
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 11703
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 7187
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 7327
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 7301
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 7373
    end
    when "3/0"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 12844
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 13656
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 13923
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 14410
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 8826
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 9077
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 9110
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 9243
    end
    when "4/0"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 15082
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 16392
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 16673
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 17483
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 10741
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 11185
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 11174
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 11409
    end
    when "250"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 16483
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 18311
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 18594
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 19779
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 12122
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 12797
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 12862
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 13236
    end
    when "300"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 18177
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 20617
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 20868
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 22525
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 13910
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 14917
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 14923
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 15495
    end
    when "350"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 19704
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 22646
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 22737
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 24904
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 15484
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 16795
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 16813
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 17635
    end
    when "400"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 20566
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 24253
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 24297
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 26916
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 16671
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 18462
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 18506
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 19588
    end
    when "500"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 22185
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 26980
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 26706
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 30096
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 18756
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 21395
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 21391
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 23018
    end
    when "600"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 22965
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 28752
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 28033
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 32154
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 20093
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 23633
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 23451
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 25708
    end
    when "750"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 24137
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 31051
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 29735
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 34605
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 21766
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 26432
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 25976
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 29036
    end
    when "1,000"
     if wire_type == 1 && conduit_type == 1 && runs_type == 1
      return 25278
    elsif wire_type == 1 && conduit_type == 1 && runs_type == 2
      return 33864
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 1
      return 31491
    elsif wire_type == 1 && conduit_type == 2 && runs_type == 2
      return 37197
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 1
      return 23478
    elsif wire_type == 2 && conduit_type == 1 && runs_type == 2
      return 29865
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 1
      return 28779
    elsif wire_type == 2 && conduit_type == 2 && runs_type == 2
      return 32938
    end
  end
end

    # Never trust parameters from the scary internet, only allow the white list through.
    def panel_params
      params.require(:panel).permit(:wire_length, :init_fault, :runs, :voltage, :c_value, :panel_name,
        :f_value, :m_value, :final_value, :project_id, :position, :wire_type, :conduit_type, :run_type,
        :wire_size, :fed_from)
    end
  end
