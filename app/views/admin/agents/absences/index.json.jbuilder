# frozen_string_literal: true

json.array! @absence_occurrences do |absence, occurrence|
  json.title absence.title
  json.start occurrence.starts_at
  json.end occurrence.ends_at
  json.backgroundColor "#7f8c8d"

  # url pour éditer l'absence
  # TODO trouver un meilleur nom à cet attribut pour en plus avoir besoin de ce commentaire
  json.url edit_admin_organisation_absence_path(absence.organisation, absence) if absence.organisation == @organisation

  json.extendedProps do
    json.organisationName absence.organisation.name
  end
end
