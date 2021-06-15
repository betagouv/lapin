# frozen_string_literal: true

class TransactionalSms::RdvCreated
  include TransactionalSms::BaseConcern

  def raw_content
    body + rdv_footer
  end

  private

  def body
    if rdv.home?
      "RDV #{rdv.motif_service_short_name} #{I18n.l(rdv.starts_at, format: :short_approx)}\n"
    else
      "RDV #{rdv.motif_service_short_name} #{I18n.l(rdv.starts_at, format: :short)}\n"
    end
  end
end
