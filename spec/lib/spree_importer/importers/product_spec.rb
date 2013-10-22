require 'spec_helper'

describe SpreeImporter::Importers::Product do
  it "should target Spree::Products" do
    @importer = SpreeImporter::Importers::Product.new
    @importer.target.should == Spree::Product
  end

  it "should set attributes on products from csv file" do
    base     = SpreeImporter::Base.new
    csv_path = "#{SpreeImporter::Engine.root}/spec/lib/go-live-order-list.csv"
    base.read csv_path
    instances = base.import :product
    instances.each do |i|
      i.name.should_not be_nil
      i.sku.should_not be_nil
      i.price.should_not be_nil
    end
  end
end
