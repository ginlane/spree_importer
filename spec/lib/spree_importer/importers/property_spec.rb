require 'spec_helper'

describe SpreeImporter::Importers::Property do

  it "should set attributes on options from csv file" do
    base     = get_importer "gin-lane-product-list"
    property = base.import :property, property_name: "color"
    property.presentation.should eql "Colors"
    property.name.should == "color"
  end
end
