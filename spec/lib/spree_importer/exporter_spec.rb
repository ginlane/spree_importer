require 'spec_helper'

describe SpreeImporter::Exporter do
  before :each do
    FactoryGirl.create :shipping_category, name: "Default"
    @product = FactoryGirl.create :product_with_option_types
    FactoryGirl.create :property, name: "fnordprop", presentation: "fnordprop"
    @product.option_types << FactoryGirl.create(:option_type, name: "fnord", presentation: "fnord")
    @product.set_property "fnordprop", "fliff"
    @headers = %w| sku name price available_on
                   [option](foo-size)Size [option]fnord fnordprop |
  end

  it "should generate headers" do
    exporter = SpreeImporter::Exporter.new
    string   = exporter.export
    @headers.each do |key|
      exporter.headers.should include(key)
    end
  end

  it "should generate mothafuckin' rows" do
    exporter = SpreeImporter::Exporter.new
    csv      = CSV.parse exporter.export, headers: true
    csv.inject(0) { |acc| acc + 1 }.should eql 1

    [ Spree::Product, Spree::Property, Spree::OptionType ].each &:destroy_all

    importer = Spree::ImportSourceFile.new data: exporter.export
    importer.import!

    product = Spree::Product.first
    product.option_types.length.should eql 2
    product.get_property("fnordprop").should eql "fliff"
    product.sku.should eql @product.sku
  end
end
