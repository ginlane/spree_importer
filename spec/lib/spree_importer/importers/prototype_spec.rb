require 'spec_helper'

describe SpreeImporter::Importers::Prototype do

  it "should set attributes on prototype from csv file" do
    FactoryGirl.create :option_type, name: "fnord", presentation: "FNORD"
    FactoryGirl.create :property, name: "red_herring", presentation: "Red Herring"

    sizes        = FactoryGirl.create :option_type, name: "sizes", presentation: "Sizes"
    style_number = FactoryGirl.create :property, name: "style_number", presentation: "Style Number"

    base         = importer "go-live-order-list"

    prototypes   = base.import :prototype, prototype_name: "category"
    prototype    = prototypes.first
    prototype.name.should eql "necklace"
    prototype.properties.length.should eql 1
    prototype.properties.first.name.should eql "style_number"
    prototype.option_types.length.should eql 1
    prototype.option_types.first.name.should eql "sizes"
  end
end
