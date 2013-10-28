require 'spec_helper'

describe SpreeImporter::Base do
  it "should read a CSV file" do
    base     = importer "go-live-order-list"
    base.csv.should_not be_nil
    base.headers.length.should == base.csv.headers.length
  end

  it "should select headers by kind" do
    base = importer "simple-sheet-annotated"
    base.find_headers("option").length.should eql 2
  end

  it "should accumulate warnings" do
    base = importer "simple-sheet-annotated"
    base.import :option, option_name: "sizes", create_record: true
    base.import :option, option_name: "sizes", create_record: true
    base.warnings[:option].first.should match /Warning/
  end
end
