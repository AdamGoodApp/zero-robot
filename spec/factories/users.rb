FactoryGirl.define do
  factory :user, class: User do
    email "ar@getautomata.com"
    password "helloworld182"
  end

  factory :user2, class: User do
    email "lb@getautomata.com"
    password "secretPASS"
  end
end