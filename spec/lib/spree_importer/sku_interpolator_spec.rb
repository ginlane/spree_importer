require 'spec_helper'

describe SpreeImporter::SkuInterpolator do

  before :each do
    @options = [
      [ "color", Spree::OptionValue.new(name: "bl", presentation: "Blue") ],
      [ "size", Spree::OptionValue.new(name: "lg", presentation: "Large") ],
      [ "weight", Spree::OptionValue.new(name: "50", presentation: "50")  ],
    ]
  end

  it "should tokenize a sku string" do
    sku_interpolator = SpreeImporter::SkuInterpolator.new "<master>-<size>-<color>"
    sku_interpolator.to_sku("MASTER", @options).should eql "MASTER-LG-BL"
  end

  it "should interpolate and tokenize a string with underscores" do
    sku_interpolator = SpreeImporter::SkuInterpolator.new "<master>_<size>_<color>"
    sku_interpolator.to_sku("MAS_TER", @options).should eql "MAS_TER_LG_BL"
  end

  it "should handle wildcards" do
    sku_interpolator = SpreeImporter::SkuInterpolator.new "<master>-*"
    sku_interpolator.to_sku("MASTER", @options).should eql "MASTER-BL-LG-50"
  end

  it "should handle wildcards with out of order options" do
    sku_interpolator = SpreeImporter::SkuInterpolator.new "<master>-<weight>-*"
    sku_interpolator.to_sku("MASTER", @options).should eql "MASTER-50-BL-LG"
  end

end
