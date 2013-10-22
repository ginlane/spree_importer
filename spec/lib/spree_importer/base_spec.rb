require 'spec_helper'

describe SpreeImporter::Base do
  it "should read a CSV file" do
    base     = SpreeImporter::Base.new
    csv_path = File.expand_path "../../", __FILE__
    csv_path = "#{csv_path}/go-live-order-list.csv"
    base.read csv_path
    # base.import
  end
end
