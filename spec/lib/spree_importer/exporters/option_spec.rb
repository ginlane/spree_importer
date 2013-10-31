require 'spec_helper'
require 'csv'
describe SpreeImporter::Exporters::Option do
  before :each do
    @exporter = SpreeImporter::Exporters::Option.new
    @product  = FactoryGirl.create :product_with_option_types
  end
  it "should append the correct fields to a row" do
    @product.option_types.first.option_values << FactoryGirl.create(:option_value)
    @product.set_property "old_gregg", "motherlicker"
    row      = CSV::Row.new %w| name [property]old_gregg [option](foo-size)Size |, [ ]
    @exporter.append row, @product
    row["[option](foo-size)Size"].should eql "(Size)S"
  end

  it "should get the correct headers" do
    @exporter.has_options?.should be_true
    option1 = @product.option_types.first
    option2 = FactoryGirl.create :option_type, name: "old_gregg", presentation: "MOTHERLICKAH"
    @product.option_types << option2

    field1  = "[option](#{option1.name})#{option1.presentation}"
    field2  = "[option](#{option2.name})#{option2.presentation}"

    headers = @exporter.headers @product
    headers.should eql [ field1, field2 ]
  end
end
