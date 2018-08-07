FactoryBot.define do
  factory :mailing_list_email do
    sequence(:email) {|x| "email#{x}@steve-pletcher.com" }

    trait :with_user do
      after :create do |mailing_list_email, eval|
        mailing_list_email.user = FactoryBot.create(:user, email: mailing_list_email.email)
        mailing_list_email.save!
      end
    end
  end
end
