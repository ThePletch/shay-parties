require "rails_helper"

RSpec.describe Markdown do
  it "renders markdown to sanitized HTML" do
    html = Markdown.html("**hello**")

    expect(html).to include("<strong>hello</strong>")
  end

  it "treats a missing body as empty" do
    expect(Markdown.html(nil)).to eq("")
  end
end
