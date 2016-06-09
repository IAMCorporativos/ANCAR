require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

puts "1. Creando settings"
  Setting.create!(key: "header_logo", value: "Logo Ayuntamiento de Madrid")
  Setting.create!(key: "org_name", value: "Ayuntamiento de Madrid")
  Setting.create!(key: "app_name", value: "Evaluación de la carga de trabajo")

puts "2. Creando tipos de organizaciones"
  to1 = OrganizationType.create!(acronym: "JD", description: "Distritos",
                 updated_by: "seed")
  to2 = OrganizationType.create!(acronym: "SGT", description: "Secretarías Generales Técnicas",
                 updated_by: "seed")
  to3 = OrganizationType.create!(acronym: "AG", description: "Áreas de Gobierno",
                 updated_by: "seed")
  to4 = OrganizationType.create!(acronym: "OOAA", description: "Organismos Autónomos",
                 updated_by: "seed")

puts "3. Creando Tipos de unidades para Distritos"
  ut1 = UnitType.create!(description: "DEPARTAMENTO DE SERVICIOS JURIDICOS", organization_type_id: to1.id, order: 1, updated_by: "seed")
  ut2 = UnitType.create!(description: "DEPARTAMENTO DE SERVICIOS TECNICOS", organization_type_id: to1.id, order: 2, updated_by: "seed")
  ut3 = UnitType.create!(description: "DEPARTAMENTO DE SERVICIOS ECONOMICOS", organization_type_id: to1.id, order: 3, updated_by: "seed")
  ut4 = UnitType.create!(description: "UNIDAD DE ACTIVIDADES CULTURALES, FORMATIVAS Y DEPORTIVAS", organization_type_id: to1.id, order: 4, updated_by: "seed")
  ut5 = UnitType.create!(description: "SECCION DE EDUCACION", organization_type_id: to1.id, order: 5, updated_by: "seed")
  ut6 = UnitType.create!(description: "DEPARTAMENTO DE SERVICIOS SOCIALES", organization_type_id: to1.id, order: 6, updated_by: "seed")
  ut7 = UnitType.create!(description: "DEPARTAMENTO DE SERVICIOS SANITARIOS, CALIDAD Y CONSUMO", organization_type_id: to1.id, order: 7, updated_by: "seed")
  ut8 = UnitType.create!(description: "SECRETARIA DE DISTRITO", organization_type_id: to1.id, order: 8, updated_by: "seed")

puts "4. Creando unidades para Distritos"
  UnitType.where(organization_type_id: to1.id).each do |u|
    Organization.where(organization_type_id: to1.id).each do |o|
      Unit.create!(description_sap: u.description, organization_id: o.id, unit_type_id: u.id, updated_by: "seed")
    end
  end

puts "5. Cargando datos Periodo 2015 Distritos"
  pdo1 = Period.create!(organization_type_id: to1.id, description: "PERIODO DE ANÁLISIS: AÑO 2015",
                 started_at: "01/01/2015", ended_at: "31/12/2015",
                 opened_at: "01/04/2016", closed_at: "30/04/2016",
                 updated_by: "seed")

puts "6. Cargando grupos de personal"
  OfficialGroup.create!(name: "A1", description: "Grupo A1")
  OfficialGroup.create!(name: "A2", description: "Grupo A2")
  OfficialGroup.create!(name: "C1", description: "Grupo C1")
  OfficialGroup.create!(name: "C2", description: "Grupo C2")
  OfficialGroup.create!(name: "E",  description: "Grupo E")

puts "7. Creando usuarios"

def create_user(ayre, name = Faker::Name.first_name,
               first_surname = Faker::Name.last_name, second_surname = Faker::Name.last_name)
  pwd = '12345678'
  puts " #{ayre}"
  User.create!(ayre: ayre, name: name, first_surname: first_surname, second_surname: second_surname)
end

admin = create_user('adm001')
admin.create_administrator

manager = create_user('man001')
manager.create_manager

valuator = create_user('val001')
valuator.create_valuator

user = create_user('usu001')

=begin
puts "8. Creando grupos de indicadores"
  IndicatorGroup.create!(description: "CONTRATOS MENORES", updated_by: "seed")
  IndicatorGroup.create!(description: "CONTRATOS DERIVADOS MARCO", updated_by: "seed")
  IndicatorGroup.create!(description: "RESTO CONTRATOS", updated_by: "seed")
  IndicatorGroup.create!(description: "TERRAZAS Y VELADORES Y CONCESIONES", updated_by: "seed")
  IndicatorGroup.create!(description: "RESTO AUTORIZACIONES (MENOS SITUADOS)", updated_by: "seed")
  IndicatorGroup.create!(description: "SITUADOS", updated_by: "seed")
  IndicatorGroup.create!(description: "DECLARACIONES Y COMUNICACIONES", updated_by: "seed")
  IndicatorGroup.create!(description: "TODO TIPO DE LICENCIAS", updated_by: "seed")
  IndicatorGroup.create!(description: "CONSULTAS URBANISTICAS Y PLANEAMIENTO", updated_by: "seed")
=end
