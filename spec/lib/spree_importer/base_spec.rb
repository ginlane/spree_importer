require 'spec_helper'

describe SpreeImporter::Base do
  it "should read a CSV file" do
    base     = importer "go-live-order-list"
    base.csv.should_not be_nil
    base.headers.length.should == base.csv.headers.length
  end
end
