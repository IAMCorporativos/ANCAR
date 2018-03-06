class Admin::RptsController < Admin::BaseController

  def index
    @year = Rpt.order(:year).last&.year
    @rpts_group = Rpt.select('year, organization_id, unit_id, den_unidad, count(*) as regs').
        group(:year, :organization_id, :unit_id, :den_unidad).
        order(:year, :organization_id, :unit_id, :den_unidad)
    @organizations = Organization.all
    @rpts = Rpt.by_year(@year).all
    respond_to do |format|
      format.html
      format.csv { send_data @rpts.to_csv }
      format.xls # { send_data @rpts.to_csv(col_sep: "\t") }
    end
  end

  def import
    if Rpt.import(params[:year], params[:file])
      message = "Fichero importado."
    else
      message = "Error en la importación."
    end
    redirect_to admin_rpts_path, notice: message
  end

  private

  def load_rpt_params
    params.permit(:file, :year)
  end

end
