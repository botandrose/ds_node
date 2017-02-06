require "spec_helper"

RSpec.describe DSNode do
  it "has a version number" do
    expect(DSNode::VERSION).not_to be nil
  end
end
