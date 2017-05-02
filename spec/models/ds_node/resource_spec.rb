require "spec_helper"
require "active_record_helper"
require "ds_node/resource"

describe DSNode::Resource do
  it "sets media_type to p for PDFs" do
    subject.file = File.open("spec/support/fixtures/example.pdf")
    expect(subject.media_type).to eq "p"
  end
end
