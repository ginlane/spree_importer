require 'spec_helper'

describe SpreeImporter::Importer do
  it "should read a CSV file" do
    base     = get_importer "go-live-order-list"
    base.csv.should_not be_nil
    base.headers.length.should == base.csv.headers.length
  end

  it "should select headers by kind" do
    base = get_importer "simple-sheet-annotated"
    base.find_headers("option").length.should eql 2
  end

  it "should accumulate warnings" do
    base = get_importer "simple-sheet-annotated"
    base.import :option, option_name: "sizes", create_record: true
    base.import :option, option_name: "sizes", create_record: true
    base.warnings[:option].first.should match /Warning/
  end
end
