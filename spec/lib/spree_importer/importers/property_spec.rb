require 'spec_helper'

describe SpreeImporter::Importers::Property do

  it "should set attributes on options from csv file" do
    base     = get_importer "bauble-bar"
    property = base.import :property, property_name: "Color"
    property.presentation.should eql "Color"
    property.name.should == "bbgl_material"
  end
end
