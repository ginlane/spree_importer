require 'spec_helper'

describe SpreeImporter::Exporter do
  before :each do
    @product = FactoryGirl.create :product_with_option_types
    FactoryGirl.create :option_value, option_type: @product.option_types.first
    FactoryGirl.create :property, name: "fnordprop", presentation: "fnordprop"
    @product.option_types << FactoryGirl.create(:option_type,
                                                name: "fnord",
                                                presentation: "Gregg",
                                                option_values: [ FactoryGirl.build(:option_value, name: "Fnord", presentation: "F")])
    @product.set_property "fnordprop", "fliff"
    @headers = %w| sku name price available_on description
                   [option](foo-size)Size [option](fnord)Gregg [property]fnordprop |
  end

  it "should generate headers" do
    exporter = SpreeImporter::Exporter.new
    string   = exporter.export
    @headers.should == exporter.headers
  end

  it "should find shit" do
    FactoryGirl.create :product_with_option_types, sku: "MOTHERLICKER"
    exporter = SpreeImporter::Exporter.new
    csv      = CSV.new exporter.export(search: { variants_including_master_sku_cont: "MOTH"}), headers: true
    rows     = csv.read
    rows.length.should eql 1
  end

  it "should generate mothafuckin' rows" do
    exporter = SpreeImporter::Exporter.new
    csv_text = exporter.export
    csv      = CSV.parse csv_text, headers: true

    csv.inject(0) { |acc| acc + 1 }.should eql 1
puts csv_text
    [ Spree::Product, Spree::Property, Spree::OptionType ].each &:destroy_all

    importer = Spree::ImportSourceFile.new data: csv_text

    importer.import!

    product = Spree::Product.first

    product.option_types.length.should eql 2
    fnord   = product.option_types.select{|ot| ot.name == "fnord" }.first
    fnord.should_not be_nil
    fnord.option_values.first.name.should eql "Fnord"
    fnord.option_values.first.presentation.should eql "F"
    product.property("fnordprop").should eql "fliff"
    product.sku.should eql @product.sku
  end
end
