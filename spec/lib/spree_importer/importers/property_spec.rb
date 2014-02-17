require 'spec_helper'

describe SpreeImporter::Importers::Property do

  it "should set attributes on options from csv file" do
    base     = get_importer "gin-lane-product-list"
    property = base.import :property, property_name: "color"
    property.presentation.should eql "Colors"
    property.name.should == "color"
  end
  it "should not create more variants than in flat spreadsheet" do
    import_source_file = get_import_source_file "gin-lane-product-list"
    import_source_file.import!

    Spree::Variant.where(sku: 'STN-FW13-WAVE-SHIRT').first.product.variants.count.should eq 12
  end
end
