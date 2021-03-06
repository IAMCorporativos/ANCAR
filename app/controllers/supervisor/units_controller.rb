class Supervisor::UnitsController < Supervisor::BaseController
  def index
    year_to_process

    @organization_types = OrganizationType.with_roles(:supervisor, current_user)
    @organization_types = OrganizationType.all if current_user.has_role? :admin

    respond_to do |format|
      format.html
      format.xls # { send_data @rpts.to_csv(col_sep: "\t") }
    end
  end

  def import
    if Rpt.import(params[:file])
      message = "Fichero importado."
    else
      message = "Error en la importación."
    end
    redirect_to admin_rpts_path, notice: message
  end

  def edit
    @organization = Organization.find(params[:id])
    @units = @organization.units
    @year = params[:year]
    @conditions = params[:conditions]
    @period = Period.where(organization_type: @organization.organization_type).by_year(@year).last
    if @period.blank?
      redirect_to supervisor_units_path(year: @year), alert: "No hay periodo abierto para el año #{@year} para #{@organization.organization_type.description}"
    end
  end

  def update
    @organization = Organization.find(params[:id])
    @units = @organization.units
    @year = params[:year]
    @period = Period.by_year(@year).by_organization_type(@organization.organization_type).take
    @error = false
    update_assigned_employees
      if @error
        flash[:error]  = t('supervisor.units_update.error', message: @old_assigned_employee.errors.messages )
      else
        flash[:notice] = t('supervisor.units_update.success')
      end
      redirect_to edit_supervisor_unit_path(params[:id], year: @year)
  end

  def export_rpt
    @organization_types = OrganizationType.all
    @organization_types = OrganizationType.find(params[:type]) if params[:type].present?
    respond_to do |format|
      format.html
      format.xls
    end
  end

  private

  def assigned_employee_params
    {
      official_group: @group, staff_of_type: 'Unit', staff_of_id: @unit_id,
      unit_id: @unit_id, period_id: @period.id, quantity: @new_quantity, updated_by: Time.zone.now
    }
  end

  def year_to_process
    @rpt_year         = Rpt.maximum(:year)
    @assignation_year = UnitRptAssignation.maximum(:year)
    @year             = params[:year].present? ? params[:year] : Period.maximum(:ended_at).year
  end

  def update_assigned_employees
    params[:unit].each do |params_unit|
      @unit_id = params_unit[0].to_i
      params_unit[1].each do |assigned_employees|
        group_name = assigned_employees[0].capitalize
        group_name = 'Agr' if group_name == 'E'
        @group = OfficialGroup.find_by(name: group_name)
        @new_quantity = assigned_employees[1].to_f
        @old_assigned_employee = Unit.find(@unit_id).assigned_employees.by_official_group(@group).by_period(@period.id).by_staff_of_type('Unit').take
        if @old_assigned_employee.blank?
          @assigned_employee = AssignedEmployee.new()
          @assigned_employee.assign_attributes(assigned_employee_params)
          unless @assigned_employee.save
            @error = true
          end
        elsif @new_quantity != @old_assigned_employee.quantity
          unless @old_assigned_employee.update_attributes(assigned_employee_params)
            @error = true
          end
        end
      end
    end
  end
end
