require 'spec_helper'

describe SpreeImporter::Importer do
  it "should read a CSV file" do
    base     = get_importer "gin-lane-product-list"
    base.csv.should_not be_nil
    base.headers.length.should == base.csv.headers.length
  end

  it "should select headers by kind" do
    base = get_importer "gin-lane-product-list"
    base.find_headers("option").length.should eql 2
  end

  it "should accumulate warnings" do
    base = get_importer "gin-lane-product-list"
    base.import :option, option_name: "size", create_record: true
    base.import :option, option_name: "size", create_record: true
    base.warnings[:option].first.should match /Warning/
  end
end
