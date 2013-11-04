require 'spec_helper'

describe Spree::ImportSourceFile do

  it "should import all the fucks" do
    source_file = FactoryGirl.create :import_source_file, :annotated
    source_file.import!
    Spree::Property.count.should eql 1
    Spree::OptionType.count.should eql 2
    Spree::Prototype.count.should eql 2
    Spree::Product.count.should eql 5
  end

  it "should implement enumerable" do
    source_file = FactoryGirl.create :import_source_file
    source_file.inject(0) { |acc| acc + 1 }.should eql 5
  end
end
