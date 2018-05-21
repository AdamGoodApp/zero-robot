FactoryGirl.define do
  factory :robot do
    name {Faker::Name.first_name}
    status "Off"
  end
end