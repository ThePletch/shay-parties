# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users rake tasks" do
  it "promotes a user to superadmin" do
    user = FactoryBot.create(:user, email: "ops@example.com")

    expect {
      invoke_task("users:make_superadmin", "ops@example.com")
    }.to output(/Promoted ops@example.com to superadmin/).to_stdout

    expect(user.reload).to be_superadmin
  end

  it "is idempotent for an existing superadmin" do
    user = FactoryBot.create(:user, :superadmin, email: "ops@example.com")

    expect {
      invoke_task("users:make_superadmin", "ops@example.com")
    }.to output(/already a superadmin/).to_stdout

    expect(user.reload).to be_superadmin
  end

  it "aborts when the user does not exist" do
    expect {
      expect {
        invoke_task("users:make_superadmin", "missing@example.com")
      }.to raise_error(SystemExit)
    }.to output(/No user found/).to_stderr
  end
end
