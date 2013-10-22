require 'spec_helper'

describe SpreeImporter::Importers::Product do
  it "should target Spree::Products" do
    @importer = SpreeImporter::Importers::Product.new
    @importer.target.should == Spree::Product
  end

  it "should set attributes on products from csv file" do
    base      = importer "go-live-order-list"
    instances = base.import :product
    instances.each do |i|
      i.name.should_not be_nil
      i.sku.should_not be_nil
      i.price.should_not be_nil
    end
  end

  it "should import products with prototypes, properties, and options" do
    FactoryGirl.create :shipping_category, name: "default"
    base         = importer "bauble-bar"

    summary      = base.import :property, property_name: "summary"
    style_number = base.import :property, property_name: "style_number"
    color        = base.import :option, option_name: "color"

    [ summary, style_number, color ].each &:save!

    necklace     = base.import :prototype, category: :necklace

    necklace.save!

    puts necklace.option_types.inspect

    products     = base.import :product
  end
end
