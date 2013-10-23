require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Spree::ImportsHelper. For example:
#
# describe Spree::ImportsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe Spree::ImportsHelper do
  it "generates import methods" do
    fake_importer = Object.new
    helper.expects(:call_import).with "options", fake_importer, %w[ fnord skidoo ]
    helper.import_options fake_importer, %w[ fnord skidoo ]
  end
end
