require 'spec_helper'

describe SpreeImporter::Importers::Product do
  it "should target Spree::Products" do
    @importer = SpreeImporter::Importers::Product.new
    @importer.target.should == Spree::Product
  end

  it "should set attributes on products from csv file" do
    base      = get_importer "gin-lane-product-list"
    instances = base.import :product
    instances.each do |i|
      i.name.should_not be_nil
      i.sku.should_not be_nil
      i.price.should_not be_nil
    end
  end

  context "importing the whole shebang" do
    before :each do
      @base         = get_importer "gin-lane-product-list"

      @material     = @base.import :property, property_name: "material", create_record: true
      @size         = @base.import :option, option_name: "size", create_record: true
      @color        = @base.import :option, option_name: "color", create_record: true
      @products     = @base.import :product
    end

    it "should import products with prototypes, properties, and options" do
      @material = @products.first.properties.first
      @material.name.should eql "material"
      @material.presentation.should eql "Material"
      @products.length.should eql 5
      @products.first.option_types.length.should eql 2
      # it should handle redundant uploads, bithc
      @base.import :product
      @products.length.should eql 5
    end

    it "shouldn't import motherlicking blank optionsfuckfuckfuckright?gotdamn" do
      @product = Spree::Variant.find_by_sku("STN-FW13-DUMMY-NO-SIZE").product

      @product.option_types.length.should eql 1
    end
  end

end
