Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :active_record # or :sequel, :redis
  strategy :default

  feature :file_attente,
          title: "File d'attente",
          description: "Permettre aux usagers de s'inscrire sur une liste d'attente"

  feature :visite_a_domicile,
          title: 'Visite à domicile',
          description: "Mise en place des visites à domicile"

  feature :corona,
          title: 'Corona',
          description: "Annonce suite au Coronavirus"
end
