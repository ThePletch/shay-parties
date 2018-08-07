FactoryBot.define do
  factory :mailing_list do
    user
    sequence(:name) {|x| "Mailing List #{x}" }

    transient do
      emails []
    end

    after :create do |mailing_list, eval|
      eval.emails.each do |email|
        mailing_list.emails << FactoryBot.create(:mailing_list_email, mailing_list: mailing_list, email: email)
      end
    end

    trait :with_emails do
      after :create do |mailing_list, eval|
        # if we've specified emails, creation will be handled by the
        # default after create hook
        if eval.emails.empty?
          2.times do
            mailing_list.emails << FactoryBot.create(:mailing_list_email, mailing_list: mailing_list)
          end
        end
      end
    end
  end
end
