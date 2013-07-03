class Prospecto < ActiveRecord::Base
	has_many :direccions, :dependent => :destroy
	has_many :interes_basicos, :dependent => :destroy
	has_many :medio_de_contactos, :dependent => :destroy
	has_many :interes_academicos, :dependent => :destroy
	has_many :accion_estrategicas, :dependent => :destroy
	has_many :plan_de_descuentos, :dependent => :destroy
	belongs_to :user
	belongs_to :sede
  belongs_to :subsede
	belongs_to :nacionalidad
	belongs_to :solicitante
  
  belongs_to :mercado_metum
  belongs_to :territorio
  belongs_to :plan_de_ventum
  belongs_to :programa
  belongs_to :grupo

	validates :nombre, :presence => true	
	validates :apellido_paterno, :presence => true
  validates_uniqueness_of :nombre, :scope => [:apellido_paterno, :apellido_materno, :fecha_de_nacimiento, :sexo, :email]
  validate :any_present?

  validates_format_of :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  def any_present?
    if %w(telefono_particular telefono_movil otro_telefono).all?{|attr| self[attr].blank?}
      errors.add :base, "Al menos un telefono es requerido"
    end
  end

  #validates :telefono_particular, :presence => true, :unless => lambda { self.otro_telefono.blank? or self.telefono_movil.blank? }
  #validates :telefono_movil, :presence => true, :unless => lambda { self.otro_telefono.blank? or self.telefono_particular.blank? }
  #validates :otro_telefono, :presence => true , :unless => lambda { self.telefono_movil.blank? or self.telefono_particular.blank? }

  	accepts_nested_attributes_for :direccions, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :interes_basicos, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :medio_de_contactos, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :interes_academicos, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :accion_estrategicas, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :plan_de_descuentos, :reject_if => :all_blank, :allow_destroy => true

  scope :my, lambda { |n| 
    {
      :conditions => ["created_by = ? or user_id = ? ", n, n]
    }
  }  
  scope :yesterday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_day - 86400]
    }
  }
  scope :tomorrow, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Date.tomorrow]
    }
  }     
  scope :today, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Date.today]
    }
  }
  scope :monday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_week(start_day = :monday)]
    }
  }
  scope :thuesday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_week(start_day = :monday) + (60*60*(24*2))]
    }
  }
  scope :wednesday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_week(start_day = :monday) + (60**(24*3))]
    }
  }
  scope :thursday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_week(start_day = :monday) + (60*6*(24*4))]
    }
  }
  scope :friday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_week(start_day = :monday) + (60*60*(24*5))]
    }
  }
  scope :saturday, lambda { 
    {
      :conditions => ["date(created_at) = date(?)", Time.now.beginning_of_week(start_day = :monday) + (60*60*(24*6))]
    }
  }
  scope :sunday, lambda { 
    {
      :conditions => ["date(created_at) >=date( )?", Time.now.beginning_of_week(start_day = :monday) + (60*60*(24*7))]
    }
  }               
    	
  def nombre_completo
    nombre + " " + apellido_paterno + " " + apellido_materno
  end 
  
  has_paper_trail

end

