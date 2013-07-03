class Solicitante < ActiveRecord::Base
	has_many :prospectos, :dependent => :destroy
	has_many :becacreditos, :dependent => :destroy
	belongs_to :examinado
	belongs_to :status_de_pago_de_examen_de_admision
	belongs_to :tipo_de_admision

	accepts_nested_attributes_for :becacreditos, :reject_if => :all_blank, :allow_destroy => true
	accepts_nested_attributes_for :prospectos, :reject_if => :all_blank, :allow_destroy => true
	#accepts_nested_attributes_for :prospectos, :reject_if => :all_blank, :allow_destroy => true
	has_paper_trail
	
	default_value_for :hora_programada_PAA do
    Time.new.beginning_of_day
	end
	default_value_for :hora_programada_pscicometrico do
    Time.new.beginning_of_day
	end
  	default_value_for :hora_programada_entrevistas do
    Time.new.beginning_of_day
	end
end
