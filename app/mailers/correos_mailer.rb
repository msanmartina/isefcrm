require 'net/http'
require 'uri'
require 'open-uri'
class CorreosMailer < ActionMailer::Base
  default from: current_user.email
  
  def enviar_correo(correo,de,adjuntos=nil)
    @correo = correo

    if adjuntos != nil
      adjuntos.each do |adjunto|
      	logger.debug Rails.root.to_s + adjunto.name_url.to_s
  		attachments[File.basename(Rails.root.to_s + "/public/" + adjunto.name_url.to_s)] = File.read(Rails.root.to_s + "/public/" + adjunto.name_url.to_s, :mode => 'rb')	
      end
    end
	
    mail(:to => "<#{de}>", :subject => "#{correo.nombredelmail}",:from=>"admin@protocrm.com")
  end  
end
