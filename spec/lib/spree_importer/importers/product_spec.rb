require 'spec_helper'

describe SpreeImporter::Importers::Product do
  it "should target Spree::Products" do
    @importer = SpreeImporter::Importers::Product.new
    @importer.target.should == Spree::Product
  end

  it "should set attributes on products from csv file" do
    base      = get_importer "go-live-order-list"
    instances = base.import :product
    instances.each do |i|
      i.name.should_not be_nil
      i.sku.should_not be_nil
      i.price.should_not be_nil
    end
  end

  it "should import products with prototypes, properties, and options" do
    base         = get_importer "bauble-bar"

    summary      = base.import :property, property_name: "summary", create_record: true
    style_number = base.import :property, property_name: "style_number", create_record: true
    color        = base.import :option, option_name: "color", create_record: true

    prototype    = base.import :prototype, prototype_name: :category, create_record: true

    products     = base.import :product
    style_number = products.first.properties.first
    style_number.name.should eql "summary"
    style_number.presentation.should eql "Summary"
    products.length.should eql 37

    # it should handle redundant uploads, bithc
    base.import :product
    products.length.should eql 37
  end
end
