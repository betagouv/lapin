module PageSpecHelper
  def expect_page_title(title)
    expect(page).to have_selector("h4.page-title", text: title)
  end

  def expect_page_with_no_record_text(text)
    expect(page).to have_selector(".card .card-body p.lead", text: text)
  end

  def rdv_title_spec(rdv)
    # TODO: remove this method and hardcode expected results for more explicit
    # specs. this method is a bad duplicate of the one in RdvsHelper
    "Le #{I18n.l(rdv.starts_at, format: :human)} (durée : #{rdv.duration_in_min} minutes)"
  end
end
