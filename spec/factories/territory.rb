FactoryBot.define do
  sequence(:territory_name) { |n| "Territoire n°#{n}" }
  sequence(:departement_number)

  factory :territory do
    name { generate(:territory_name) }
    departement_number { generate(:departement_number) }
  end
end
