require "spec_helper"

describe "Product Decorator" do
  it "should set a sku on the variant" do
    product = FactoryGirl.create :product_with_option_types, sku: "MASTER"
    variant = FactoryGirl.create :variant, product: product
    product.set_sku variant
    variant.sku.should eql "MASTER-SIZE"
  end
end
