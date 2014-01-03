class ImportsController < ApplicationController
  require 'csv' 
  require 'iconv'

  def uploadcsv
    @import = Import.find(params[:id])
        all_ok = true
        @errores= []
        @errordetails=[]
        @objecto = nil
        @theobject = nil
        begin
        csv_text = File.read("public/" + @import.filename_url.to_s)
        utf8_string = Iconv.iconv('utf-8', 'iso8859-1', csv_text).first
        csv = CSV.parse(utf8_string.gsub('"', '').gsub(/[^\n\r;]+/, '"\0"').gsub(';', ','), :headers => true) 

        csv.each do |row| 
          begin
            logger.debug "INFO************************************************"
            logger.debug row

            row = row.to_hash.with_indifferent_access 
            prospecto=row
            direccion= row.to_hash            
            logger.debug "INFO************************************************" 
            #remove extra fields
            if prospecto["nombre"] == "*Nombre(s):" 
              
            elsif prospecto["sexo"] != nil

              if prospecto["sexo"].gsub(/\s+/, "").upcase == "MASCULINO"
                  prospecto["sexo"] = true
              else
                  prospecto["sexo"] = false
              end

              prospecto.delete("calle")
              prospecto.delete("no_exterior")
              prospecto.delete("no_interior")
              prospecto.delete("codigo_postal")
              prospecto.delete("colonia")
              prospecto.delete("delegacion_municipio")
              prospecto.delete("medio_de_contacto")
              prospecto.delete("nacionalidad")
              prospecto.delete("programa")
              prospecto.delete("nivel")
              prospecto.delete("estado")
              prospecto.delete("pais")
              prospecto.delete("commentarios")
              prospecto.delete("ultimo_grado_de_estudio")
              prospecto.delete("ultimo_grado_de_estudios")
              prospecto.delete("preparatoria_o_universidad_de_origen")
              prospecto.delete("municipio_de_la_preparatoria_o_universidad_de_origen")
              prospecto.delete("ano_de_graduacion")
              prospecto.delete("turno")
              prospecto.delete("modalidad")
              prospecto.delete("periodo_para_ingresar")
              prospecto.delete("interes_academico_1")
              prospecto.delete("interes_academico_2")
              prospecto.delete("interes_academico_3")
              prospecto.delete("descuento_en_la_inscripcion")
              prospecto.delete("porcentaje")
              prospecto.delete("fecha_de_caducidad")
              prospecto.delete("otro_cual")
              prospecto.delete("status_de_interes_de_prospecto_validado")
              prospecto["email"] = prospecto["email"].gsub(" ","")

              @objecto = eval(@import.module.singularize.camelize).create!(prospecto.to_hash.symbolize_keys)

              logger.debug "1#######################################################################"
                if(@import.module.singularize.camelize=="Prospecto")
                  @objecto.importado_revisado=false
                  @objecto.issolicitante=false
                  @objecto.archivado =false
                  @objecto.created_by = current_user.id
                  @objecto.user_id =current_user.id
                  @objecto.sede_id =current_user.sede_id
                  @objecto.accion_estrategicas.build
                
                  if direccion["nacionalidad"] != nil
                      @nacionalidad = Nacionalidad.where(:nacionalidad=>direccion["nacionalidad"],:pais=>direccion["pais"]).first
                      if @nacionalidad == nil
                        @nacionalidad = Nacionalidad.create(:nacionalidad=>direccion["nacionalidad"],:pais=>direccion["pais"])
                        @nacionalidad.save
                      end
                      logger.debug "==========================="
                      logger.debug @nacionalidad.inspect
                      logger.debug "==========================="
                      @objecto.nacionalidad_id = @nacionalidad.id
                  end
                  
                  if  direccion["programa"] != nil
                      @programa = Programa.find_or_create_by_programa_and_nivel(direccion["programa"],direccion["nivel"])
                      if direccion["nivel"] != nil
                        @programa.nivel = direccion["nivel"]
                        @programa.save
                      end
                      @objecto.programa_id = @programa.id
                  end
                  

                  #direccions
                  @objecto.direccions.build
                  @objecto.direccions.first.calle=direccion["calle"]
                  @objecto.direccions.first.no_exterior=direccion["no_exterior"]
                  @objecto.direccions.first.no_interior=direccion["no_interior"]
                  @objecto.direccions.first.codigo_postal=direccion["codigo_postal"]
                  @objecto.direccions.first.colonia=direccion["colonia"]
                  @objecto.direccions.first.delegacion_municipio=direccion["delegacion_municipio"]
                  @objecto.direccions.first.estado=direccion["estado"]
                  @objecto.direccions.first.pais=direccion["pais"]
                  #interes basicos
                  @objecto.interes_basicos.build
                  @objecto.interes_basicos.first.comentarios = direccion["commentarios"]
                  if direccion["nivel"] != nil
                      @nivel = Nivel.find_or_create_by_valor(direccion["nivel"])
                       @objecto.interes_basicos.first.nivel_id = @nivel.id
                  end                
                  if direccion["ultimo_grado_de_estudio"] != nil
                      @ultimo_grado_de_estudio = UltimoGradoDeEstudio.find_or_create_by_grado_de_estudio(direccion["ultimo_grado_de_estudio"])
                       @objecto.interes_basicos.first.ultimo_grado_de_estudio_id = @ultimo_grado_de_estudio.id
                  end
                  
                  if direccion["preparatoria_o_universidad_de_origen"] != nil or direccion["preparatoria_o_universidad_de_origen"] != nil
                      @preparatoria_o_universidad_de_origen = PreparatoriaOUniversidadDeOrigen.find_or_create_by_valor(direccion["preparatoria_o_universidad_de_origen"])
                      @objecto.interes_basicos.first.preparatoria_o_universidad_de_origen_id = @preparatoria_o_universidad_de_origen.id
                  end
                
                  if direccion["municipio_de_la_preparatoria_o_universidad_de_origen"] != nil
                      @municipio_de_la_preparatoria_o_universidad_de_origen = MunicipioDeLaPreparatoriaOUniversidadDeOrigen.find_or_create_by_valor(direccion["municipio_de_la_preparatoria_o_universidad_de_origen"])
                      @objecto.interes_basicos.first.municipio_de_la_preparatoria_o_universidad_de_origen_id = @municipio_de_la_preparatoria_o_universidad_de_origen.id
                  end
                  @objecto.interes_basicos.first.ano_de_graduacion=direccion["ano_de_graduacion"]

     
                  if direccion["turno"] != nil
                      @turno = Turno.find_or_create_by_valor(direccion["turno"])
                      @objecto.interes_basicos.first.turno_id = @turno.id
                  end
                  if direccion["modalidad"] != nil
                      @modalidad = Modalidad.find_or_create_by_valor(direccion["modalidad"])
                      @objecto.interes_basicos.first.modalidad_id = @modalidad.id
                  end              
                  if direccion["periodo_para_ingresar"] != nil
                      @periodo_para_ingresar = PeriodoParaIngresar.find_or_create_by_valor(direccion["periodo_para_ingresar"])
                      @objecto.interes_basicos.first.periodo_para_ingresar_id = @periodo_para_ingresar.id
                  end              
                  logger.debug "2#######################################################################"
                  #medio de contactos
                  @objecto.medio_de_contactos.build
                  @objecto.medio_de_contactos.first.otro_texto = direccion["medio_de_contacto"]
                  #interes academicos
                  @objecto.interes_academicos.build
                  @objecto.interes_academicos.first.opcion_1 = direccion["interes_academico_1"]
                  @objecto.interes_academicos.first.opcion_2 = direccion["interes_academico_2"]
                  @objecto.interes_academicos.first.opcion_3 = direccion["interes_academico_3"]

                  #plan de descuentos
                  @objecto.plan_de_descuentos.build    
                  @objecto.plan_de_descuentos.first.descuento_en_la_inscripcion = direccion["descuento_en_la_inscripcion"]              
                  @objecto.plan_de_descuentos.first.porcentaje = direccion["porcentaje"]
                  @objecto.plan_de_descuentos.first.fecha_de_caducidad = direccion["fecha_de_caducidad"]
                  @objecto.plan_de_descuentos.first.otro_cual = direccion["otro_cual"]
                  @theobject = @objecto
                  if @objecto.save!( :validate => false )
                    all_ok = true
                    historial = History.new
                    historial.model_name = "prospectos"
                    historial.model_id = @objecto.id
                    historial.user_id = current_user.id
                    historial.role = current_user.role
                    historial.action = "Importado"
                    historial.save                                        
                  else
                     logger.debug "444#######################################################################"
                    flash[:error] << "Failed to create: #{object.title}. Errors: #{@objecto.errors.full_messages.join(', ')}."
                  end                   
                end
            end
          rescue => error
            logger.debug "ERROR#######################################################################ERROR"
            @errordetails.push([row,error])
            logger.debug row
            logger.debug error.inspect
            @errores.push(error)
            logger.debug "ERROR#######################################################################ERROR"
            next
          end
        end

          rescue => error
            logger.debug "ERROR#######################################################################ERROR"
            logger.debug error.inspect
            @errores.push(error)
            logger.debug "ERROR#######################################################################ERROR"
          end
    #rescue => error
    #  flash[:error] =error
    #  render :uploadcsv
  end
  # GET /imports
  # GET /imports.json
  def index
    @imports = Import.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @imports }
    end
  end

  # GET /imports/1
  # GET /imports/1.json
  def show
    @import = Import.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @import }
    end
  end

  # GET /imports/new
  # GET /imports/new.json
  def new
    @import = Import.new


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @import }
    end
  end

  # GET /imports/1/edit
  def edit
    @import = Import.find(params[:id])
  end

  # POST /imports
  # POST /imports.json
  def create
    @import = Import.new(params[:import])
      @import.whenimported = DateTime.now
      @import.modu = "prospectos"
      @import.module = "prospectos"
    respond_to do |format|
      if @import.save

        format.html { redirect_to uploadcsv_path(@import), notice: 'Import was successfully created.' }
        format.json { render json: @import, status: :created, location: @import }
      else
        format.html { render action: "new" }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /imports/1
  # PUT /imports/1.json
  def update
    @import = Import.find(params[:id])

    respond_to do |format|
      @import.whenimported = DateTime.now
      if @import.update_attributes(params[:import])
        format.html { redirect_to @import, notice: 'Import was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1
  # DELETE /imports/1.json
  def destroy
    @import = Import.find(params[:id])
    @import.destroy

    respond_to do |format|
      format.html { redirect_to imports_url }
      format.json { head :ok }
    end
  end
end
