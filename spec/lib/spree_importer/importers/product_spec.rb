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

  it 'should set :batch_id on instances' do
    base      = get_importer "gin-lane-product-list"
    instances = base.import :product, {batch_id: 668}
    instances.each do |i|
      i.batch_id.should == 668
      i.variants.each do |v|
        v.batch_id.should == v.batch_id
      end
    end
  end

  it "should throw an exception for a badlly formatted date string" do
    csv      = CSV.parse "available_on\ninvalidate", headers: true
    headers  = { "available-on" => SpreeImporter::Field.new("available-on", headers: true, index: 0) }
    importer = SpreeImporter::Importers::Product.new

    importer.each_instance(headers.with_indifferent_access, csv){ }
    importer.errors.length.should eql 1
    importer.errors.first.row.should eql 1
    importer.errors.first.column.should eql "available_on"
  end

  context "importing the whole shebang" do
    before :each do
      @base         = get_importer "gin-lane-product-list"

      @material     = @base.import :property, property_name: "material", create_record: true
      @size         = @base.import :option, option_name: "size", create_record: true
      @color        = @base.import :option, option_name: "color", create_record: true
      @taxonomies   = @base.import :taxonomy
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

      product = Spree::Variant.find_by_sku("STN-FW13-DUMMY-NO-SIZE").product
      product.taxons.count.should eql 1
      product.taxons.first.pretty_name.should eql "Hat -> UBERHAT"
    end
    it "should generate skus for variants" do
      product = Spree::Variant.find_by_sku("STN-FW13-DUMMY-NO-SIZE").product
      product.variants.each do |v|
        v.sku.should eql "#{product.sku}-#{v.option_values.first.name.upcase}"
      end
    end

    it "shouldn't import motherlicking blank optionsfuckfuckfuckright?gotdamn" do
      @product = Spree::Variant.find_by_sku("STN-FW13-DUMMY-NO-SIZE").product

      @product.option_types.length.should eql 1
    end

    it "should import a sku pattern if specified" do
      @products[0].sku_pattern.should eql SpreeImporter.config.default_sku
      @products[1].sku_pattern.should eql "<master>-<color>-<size>"
    end
  end

end
