require 'rails_helper'

feature "Entry Indicators" do

  describe "muestra datos de una unidad " do
    it 'primera unidad de la organización' do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      click_link("Procesos y subprocesos", :match => :first)
      click_link('Periodo de análisis de datos Distritos (Cerrado)', :match => :first)
      within('div#unit') do
        expect(page).to have_content 'DEPARTAMENTO DE SERVICIOS JURIDICOS'
      end
    end

    it 'cambia de unidad' do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)

      click_link("Procesos y subprocesos", :match => :first)
      click_link('Periodo de análisis de datos Distritos (Cerrado)', :match => :first)
      click_link 'SECRETARIA DE DISTRITO'
      within('div#unit') do
        expect(page).to have_content 'SECRETARIA DE DISTRITO'
      end
    end

    it 'muestra efectivos de unidad' do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      add_staff("Unit", unit.id, unit.id, period, 1, 0.5, 1, 0.5)
      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link 'Periodo de análisis de datos Distritos (Cerrado)'
      end

      within("table#staff_Unit") do
        expect(page).to have_content("1,0", count: 2)
        expect(page).to have_content("0,5", count: 2)
      end
    end
  end

  describe "Process" do
    it ' show SGT data' do
      user= create(:user, :SGT)
      login_as_authenticated_user(user)

      organization_role = Organization.find_roles(:interlocutor, user).first

      organization = Organization.find(organization_role.resource_id)
      unit = organization.units.first


      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link('Periodo de análisis de datos SGT 2 (Cerrado)')
      end

      expect(page).to have_content 'SECRETARIA GENERAL TECNICA DEL AREA DE GOBIERNO DE DESARROLLO URBANO SOSTENIBLE'
      expect(page).to have_content '1. RÉGIMEN JURÍDICO'
      expect(page).to have_content '1.1. ASUNTOS JUNTA GOBIERNO, PLENO Y COMISIONES DEL PLENO'
      expect(page).to have_content  '- Revisión jurídica, preparación de documentación y petición de inforems de los asuntos a tratar en la Comisión Preparatoria ..'
      expect(page).to have_content 'Nº informes solicitados por otras Áreas de Gobierno'
      expect(page).to have_content 'Nº de asuntos tratados en la Junta de Gobierno'
      expect(page).to have_content '1.2. PROYECTOS NORMATIVOS'
      expect(page).to have_content 'Preparación revisión y tramitación de proyectos normativos ...'
      expect(page).to have_content 'Nº de proyectos de otras Áreas	Elaboración Propia'
  end
    it ' show Distritos data' do
      user= create(:user, :distrito)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link 'Periodo de análisis de datos Distritos (Cerrado)'
      end

      expect(page).to have_content 'TRAMITACIÓN Y SEGUIMIENTO DE CONTRATOS Y CONVENIOS DEPARTAMENTO JURIDICO'
      expect(page).to have_content 'TRAMITACIÓN Y SEGUIMIENTO DE CONTRATOS Y CONVENIOS DEPARTAMENTO TÉCNICO'

    end
    it ' actualiza indicadores y puestos ' do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      fill_in 'Indicator_1_A1', with: '10,9'
      fill_in 'IndicatorMetric_1_2', with: '5143'

      click_on 'Guardar datos'

      expect(page).to have_content "Se han guardado los datos. Cuando se finalice la entrada de datos es necesario verificarlos mediante el botón 'Finalizar entrada de datos'"
      expect(page).to have_content "10,90"
    end
  end

  describe 'formulario de actualización' do
    it 'es editable si usuario con permiso y periodo abierto' do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      expect(page).to have_selector(:link_or_button, 'Guardar datos')
      expect(page).to have_selector(:link_or_button, 'Finalizar entrada de datos')
      expect(page).to have_selector(:link_or_button, 'Imprimir')

      expect(page).to have_css('input#Indicator_1_A1')
      expect(page).to have_css("input#IndicatorMetric_2_3")
    end

    it 'no es editable si usuario con permiso y periodo cerrado' do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.save

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link 'Periodo de análisis de datos Distritos (Cerrado)'
      end

      expect(page).not_to have_selector(:link_or_button, 'Guardar datos')
      expect(page).not_to have_selector(:link_or_button, 'Finalizar entrada de datos')
      expect(page).to have_selector(:link_or_button, 'Imprimir')

      expect(page).not_to have_css("input#Indicator_1_A1")
      expect(page).not_to have_css("input#IndicatorMetric_2_3")
    end

    it 'no es editable si usuario sin permiso aunque periodo abierto' do
      user= create(:user, :validator)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:validator, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      expect(page).not_to have_selector(:link_or_button, 'Guardar datos')
      expect(page).not_to have_selector(:link_or_button, 'Finalizar entrada de datos')
      expect(page).to have_selector(:link_or_button, 'Imprimir')

      expect(page).not_to have_css("input#Indicator_1_A1")
      expect(page).not_to have_css("input#IndicatorMetric_2_3")
    end

    it 'no es editable si periodo abierto con VºBº del validador' do
      user= create(:user, :interlocutor_distrito)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      Approval.add(period, unit, 'Visto bueno de la unidad', user)

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      expect(page).not_to have_selector(:link_or_button, 'Guardar datos')
      expect(page).not_to have_selector(:link_or_button, 'Finalizar entrada de datos')
      expect(page).to have_selector(:link_or_button, 'Imprimir')

      expect(page).not_to have_css("input#Indicator_1_A1")
      expect(page).not_to have_css("input#IndicatorMetric_2_3")
    end

  end

  describe "Visto Bueno de los datos de entrada" do
    it 'es posible por validador de la unidad con perido abierto' do
      user = create(:user, :validator)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:validator, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end
      expect(page).to have_content('Datos pendientes de Visto Bueno')
      click_on 'Visto bueno'
#      Approval.add(period, unit, 'Visto bueno de la unidad', user)
#
      expect(page).to have_content(' Visto bueno actualizado correctamente')
      expect(page).to have_content('Visto bueno a los datos de esta hoja')
      expect(page).to have_content('El/la ' + user.full_name)
      expect(page).to have_content('Observaciones:')
      expect(page).to have_css('textarea#comments')

      expect(page).to have_selector(:link_or_button, 'Modificar observaciones')
      expect(page).to have_selector(:link_or_button, 'Generar PDF Resumen')
      expect(page).to have_selector(:link_or_button, 'Cancelar el VºBº')
    end

    it 'cancelar VB ' do
      user = create(:user, :validator)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:validator, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)

      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      click_on 'Visto bueno'
      click_on 'Cancelar el VºBº'
      expect(page).to have_content('Datos pendientes de Visto Bueno')
    end

    it 'no posible con periodo cerrado' do
      user = create(:user, :validator)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:validator, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first

#      Approval.add(period, unit, 'Visto bueno de la unidad', user)
      click_link("Procesos y subprocesos", :match => :first)
      within("#organization_#{organization.id}") do
        click_link 'Periodo de análisis de datos Distritos (Cerrado)'
      end

      expect(page).not_to have_selector(:link_or_button, 'Visto bueno')
      expect(page).to have_selector(:link_or_button, 'Imprimir')
    end
  end

  describe "Validaciones de entrada de datos: " do
    it " todos los datos cumplimentados " do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)
      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      fill_in 'Indicator_1_A1', with: '10,9'
      fill_in 'IndicatorMetric_1_2', with: '543'
      fill_in 'IndicatorMetric_1_1', with: '13'
      fill_in 'Indicator_2_A1', with: '10,9'
      fill_in 'IndicatorMetric_2_3', with: '151'

      click_on 'Finalizar entrada de datos'

      expect(page).not_to have_content 'Error en la cumplimentación de indicadores'
    end
    it " error: indicadores sin cumplimentar " do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)
      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      fill_in 'Indicator_1_A1', with: '10,9'
      fill_in 'IndicatorMetric_1_2', with: '543'
      fill_in 'IndicatorMetric_1_1', with: '13'
      fill_in 'Indicator_2_A1', with: '10,9'

      click_on 'Finalizar entrada de datos'

      expect(page).to have_content 'Error en la cumplimentación de indicadores'
      expect(page).to have_content  'Expedientes urbanísticos => cantidad: 0.0 puestos asignados: 10.9'
    end
    it " Error en la cumplimentación de la plantilla asignada a los indicadores " do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)
      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      fill_in 'Indicator_1_A1', with: '10,9'
      fill_in 'IndicatorMetric_1_2', with: '543'
      fill_in 'IndicatorMetric_1_1', with: '13'
      fill_in 'Indicator_2_A1', with: nil
      fill_in 'IndicatorMetric_2_3', with: '13'

      click_on 'Finalizar entrada de datos'
      expect(page).to have_content 'Error en la cumplimentación de la plantilla asignada a los indicadores'
      expect(page).to have_content  'Expedientes urbanísticos => Grupo A1
'
    end
    it " Error: indicadores no tiene asignada plantilla " do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)
      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      fill_in 'Indicator_1_A1', with: '10,9'
      fill_in 'IndicatorMetric_1_2', with: '543'
      fill_in 'IndicatorMetric_1_1', with: '13'
      fill_in 'IndicatorMetric_2_3', with: '151'

      click_on 'Finalizar entrada de datos'

      expect(page).to have_content 'Error en la asignación de plantilla a indicadores'
      expect(page).to have_content  'Expedientes urbanísticos => cantidad: 151.0 puestos asignados: 0.0'
    end
    it " error: Error plantilla de la unidad no coincide con la suma de la de indicadores " do
      user= create(:user, :with_two_organizations)
      login_as_authenticated_user(user)
      organization_role = Organization.find_roles(:interlocutor, user).first
      organization      = Organization.find(organization_role.resource_id)
      unit = organization.units.first

      period = Period.first
      period.opened_at = Date.today - 1
      period.closed_at = Date.today + 1
      period.save

      click_link("Procesos y subprocesos", :match => :first)
      within("#organization_#{organization.id}") do
        click_link period.description + " (" + I18n.t('status.open') + ' de ' +
                       (I18n.l period.opened_at) + ' a ' + (I18n.l period.closed_at) + ')'
      end

      fill_in 'Indicator_1_A1', with: '1,9'
      fill_in 'IndicatorMetric_1_2', with: '543'
      fill_in 'IndicatorMetric_1_1', with: '13'
      fill_in 'Indicator_2_A1', with: '2,9'
      fill_in 'IndicatorMetric_2_3', with: '151'

      click_on 'Finalizar entrada de datos'

      expect(page).to have_content 'Error en la plantilla asignada a indicadores'
      expect(page).to have_content 'Grupo A1'

      expect(page).to have_content('Adecuar puestos')
    end
  end
end
