require "administrate/base_dashboard"

class AbsenceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    agent: Field::BelongsTo,
    organisation: Field::BelongsTo,
    id: Field::Number,
    title: Field::String,
    first_day: Field::DateTime,
    end_day: Field::DateTime,
    start_time: Field::Time,
    end_time: Field::Time,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [:agent, :organisation, :id, :title].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [:agent, :organisation, :id, :title, :first_day, :start_time, :end_day, :end_time, :created_at, :updated_at].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [:agent, :organisation, :title, :first_day, :start_time, :end_day, :end_time].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how absences are displayed
  # across all pages of the super_admin dashboard.
  #
  # def display_resource(absence)
  #   "Absence ##{absence.id}"
  # end
end
