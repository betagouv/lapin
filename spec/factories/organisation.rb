FactoryBot.define do
  sequence(:orga_name) { |n| "Organisation n°#{n}" }

  factory :organisation do
    name { generate(:orga_name) }
    territory { Territory.first || association(:territory) }
  end
end
