# frozen_string_literal: true

namespace :users do
  desc "Promote a user to superadmin by email (idempotent). Usage: bin/rails users:make_superadmin[email@example.com]"
  task :make_superadmin, [:email] => :environment do |_t, args|
    email = args[:email].to_s.strip
    abort "Usage: bin/rails users:make_superadmin[email@example.com]" if email.blank?

    user = User.find_by(email: BannedEmail.normalize(email))
    abort "No user found with email #{email}" unless user

    if user.superadmin?
      puts "#{user.email} is already a superadmin."
    else
      user.make_superadmin!
      puts "Promoted #{user.email} to superadmin."
    end
  end
end
