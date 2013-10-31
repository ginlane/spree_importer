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
  context "importing the whole shebang" do
    before :each do
      @base         = get_importer "simple-sheet-annotated"

      @summary      = @base.import :property, property_name: "grid_order", create_record: true
      @style_number = @base.import :property, property_name: "style_number", create_record: true
      @sizes        = @base.import :option, option_name: "sizes", create_record: true
      @fnords       = @base.import :option, option_name: "fnords", create_record: true
      @products     = @base.import :product
    end

    it "should import products with prototypes, properties, and options" do
      @grid_order = @products.first.properties.first
      @grid_order.name.should eql "grid_order"
      @grid_order.presentation.should eql "Grid Order"
      @products.length.should eql 37

      # it should handle redundant uploads, bithc
      @base.import :product
      @products.length.should eql 37
    end

    it "shouldn't import motherlicking blank optionsfuckfuckfuckright?gotdamn" do
      @product = Spree::Variant.find_by_sku("0002_KK_GL").product
      @product.option_types.length.should eql 1 # NO FNORDS
    end
  end
end
