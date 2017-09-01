namespace :entry_indicators do
  require 'spreadsheet'

  desc "Importar entry_indicators"
  task import: :environment do
    puts ENV['period']
    puts ENV['filename']
    if ENV['period'].nil? || ENV['filename'].nil?
      p '**'
      p '** ERROR: debe indicar id del periodo y file: rake entry_indicators:import period=10 filename=../nombrefichero.xls'
      p '**'
      exit
    end

    period = Period.find(ENV['period'].to_i)
    p 'Importing entry_indicators: ' + period.description + ', fichero: ' +ENV['filename']

    book  = Spreadsheet.open ENV['filename']
    sheet = book.worksheet 0
    @indicator_metrics = Hash.new

    (sheet.rows).each do |row|
      next if row[0].nil?
      # Obtiene los entry_indicadores a cargar
      if row[0] == 'INDICADORES'
        (3..(row.count-1)).each do |n|
          @indicator_metrics[n] =  row[n] if row[n].integer?
        end
        next
      end

      # Trata cada SGT
      data = Hash.new
      data['period_id'] = period.id
      data['unit_id'] = row[1].to_i
      p 'Tratando Unidad: ' + data['unit_id'].to_s

      @indicator_metrics.to_a.each do |indicator_metric|
        data['indicator_metric'] = indicator_metric[1]
        data['amount'] = row[indicator_metric[0]]
        data['imported_amount'] = row[indicator_metric[0]]
        data['updated_by'] = 'import'
        p " * Tratando indicator: " + data.to_s
        if data['amount'].nil?
          p '  ** AMOUNT  nulo, registro no se trata'
          next
        end
        entry_indicator = EntryIndicator.create_from_import(data)
        if entry_indicator.save
          p "  ** Creado entry_indicator: " + entry_indicator.indicator_metric.id.to_s + ' - ' + entry_indicator.indicator_metric.metric.item.description
        else
          p "  ** ERROR no creado entry_indicator: " + entry_indicator.indicator_metric.id.to_s + ' - ' + entry_indicator.indicator_metric.metric.item.description
        end
      end

    end
  end

  desc "Initialize code for a range of regs, mode: order/reg --- "
  task initialize_code: :environment do
#   Rango de resgistros a tratar
    inicio = ENV['init'].to_i
    fin    = ENV['end'].to_i

#   Mode:  indica como se actualizan el nuevo campo code partiendo de order o del id del registro:
    mode   = ENV['mode']

    p 'Initializing indicator code between: ' + inicio.to_s + '-' + fin.to_s + ' ,update mode: ' + mode
    (inicio..fin).each do |i|
      indicator = Indicator.find_by(id: i)
      unless indicator.nil?
        p '...updating reg: ' + indicator.id.to_s
        if mode == 'order'
          indicator.code = indicator.order
        elsif mode == 'reg'
          indicator.code = indicator.id
        end
        indicator.save
      end
    end
  end

end
