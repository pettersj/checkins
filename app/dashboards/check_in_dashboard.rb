require "administrate/base_dashboard"

class CheckInDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    account: Field::BelongsTo,
    user: Field::BelongsTo,
    answers: Field::HasMany,
    subscribers: Field::HasMany,
    members: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    schedule_period: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    weekday: Field::String,
    time: Field::Time,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    start_date: Field::Date,
    status: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    last_sent: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  account
  user
  answers
  subscribers
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  account
  user
  answers
  subscribers
  members
  id
  name
  schedule_period
  weekday
  time
  created_at
  updated_at
  start_date
  status
  last_sent
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  account
  user
  answers
  subscribers
  members
  name
  schedule_period
  weekday
  time
  start_date
  status
  last_sent
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how check ins are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(check_in)
  #   "CheckIn ##{check_in.id}"
  # end
end
