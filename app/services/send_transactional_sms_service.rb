class SendTransactionalSmsService < BaseService
  include Rails.application.routes.url_helpers

  attr_reader :user, :rdv, :from, :type

  def initialize(type, rdv, user, options = {})
    @type = type
    @user = user
    @rdv = rdv
    @options = options
    @from = "RdvSoli"
  end

  def perform
    sms_params = {
      sender: @from,
      recipient: @user.phone_number_formatted,
      content: replace_special_chars(send(@type)),
      tag: [ENV["APP"], @rdv.organisation.id, @type].join(" ")
    }
    if Rails.env.production?
      sib_transac_sms = SibApiV3Sdk::SendTransacSms.new(sms_params)
      SibApiV3Sdk::TransactionalSMSApi.new.send_transac_sms(sib_transac_sms)
    else
      Rails.logger.debug("following SMS would have been sent in production environment: #{sms_params}")
    end
  end

  private

  def replace_special_chars(body)
    body.tr("áâãëẽêíïîĩóôõúûũçÀÁÂÃÈËẼÊÌÍÏÎĨÒÓÔÕÙÚÛŨ", "aaaeeeiiiiooouuucAAAAEEEEIIIIIOOOOUUUU")
  end

  def sms_footer
    message = if @rdv.phone?
                "RDV Téléphonique\n"
              elsif @rdv.home?
                "RDV à domicile\n#{@rdv.address}\n"
              else
                "#{@rdv.address_complete}\n"
              end
    message += "Infos et annulation: #{rdvs_shorten_url(host: ENV['HOST'])}"
    message += " / #{@rdv.organisation.phone_number}" if @rdv.organisation.phone_number
    message
  end

  def rdv_created
    message = if @rdv.home?
                "RDV #{@rdv.motif.service.short_name} #{I18n.l(@rdv.starts_at, format: :short_approx)}\n"
              else
                "RDV #{@rdv.motif.service.short_name} #{I18n.l(@rdv.starts_at, format: :short)}\n"
              end
    message += sms_footer
    message
  end

  def rdv_cancelled
    message = "RDV #{@rdv.motif.service.short_name} #{I18n.l(@rdv.starts_at, format: :short)} a été annulé\n"
    message += if @rdv.organisation.phone_number
                 "Appelez le #{@rdv.organisation.phone_number} ou allez sur https://rdv-solidarites.fr pour reprendre RDV."
               else
                 "Allez sur https://rdv-solidarites.fr pour reprendre RDV."
               end
    message
  end

  def reminder
    message = if @rdv.home?
                "Rappel RDV #{@rdv.motif.service.short_name} le #{I18n.l(@rdv.starts_at, format: :short_approx)}\n"
              else
                "Rappel RDV #{@rdv.motif.service.short_name} le #{I18n.l(@rdv.starts_at, format: :short)}\n"
              end
    message += sms_footer
    message
  end

  def file_attente
    message = "Des créneaux se sont libérés plus tôt.\n"
    message += "Cliquez pour voir les disponibilités : #{users_creneaux_index_url(rdv_id: @rdv.id, host: ENV['HOST'])}"
    message
  end
end
