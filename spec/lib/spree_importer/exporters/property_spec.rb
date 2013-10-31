require 'spec_helper'

describe SpreeImporter::Exporters::Property do
  it "should append the correct fields to a row" do
    exporter = SpreeImporter::Exporters::Property.new
    product  = FactoryGirl.create :product_with_option_types
    product.set_property "old_gregg", "motherlicker"
    row      = CSV::Row.new %w| name [property]old_gregg [option](foo-size)Size |, [ ]
    exporter.append row, product
    row["[property]old_gregg"].should eql "motherlicker"
  end
end
