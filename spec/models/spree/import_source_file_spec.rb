require 'spec_helper'

describe Spree::ImportSourceFile do
  it "should return a csv file" do
    source_file = Spree::ImportSourceFile.new data: "col1,col2,col3", mime: "text/csv"
    source_file.csv?.should be_true
  end

  it "should import all the fucks" do
    FactoryGirl.create :shipping_category, name: "Default"
    source_file = FactoryGirl.create :import_source_file, :annotated
    source_file.import!
    Spree::Property.count.should eql 3
    Spree::OptionType.count.should eql 2
    Spree::Prototype.count.should eql 4
    Spree::Product.count.should eql 34
  end
end
