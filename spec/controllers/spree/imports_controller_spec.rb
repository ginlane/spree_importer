require 'spec_helper'

describe Spree::ImportsController do
  before :each do
    @csv = fixture_file_upload "/files/bauble-bar.csv", "text/csv"
  end

  it "should import options from spreadsheet" do
    expect {
      spree_post :create, import: @csv, targets: { options: %w[ color size ] }
    }.to change(Spree::OptionType, :count).by(2)
  end

  it "should import properties from spreadsheet" do
    expect {
      spree_post :create, import: @csv, targets: { properties: %w[ summary style_number ]}
    }.to change(Spree::Property, :count).by(2)
  end

  it "should import protoypes from spreadsheet" do
    expect {
      spree_post :create, import: @csv, targets: { prototypes: %w[ necklace ring ]}
    }.to change(Spree::Prototype, :count).by(2)
  end

  context "with a populated db" do
    before :each do
      FactoryGirl.create :shipping_category, name: "default"
      base         = importer "bauble-bar"

      summary      = base.import :property, property_name: "summary"
      style_number = base.import :property, property_name: "style_number"
      color        = base.import :option, option_name: "color"

      [ summary, style_number, color ].each &:save!

      necklace     = base.import :prototype, prototype_name: :necklace

      necklace.save!
    end

    it "should import products from spreadsheet" do
      expect {
        spree_post :create, import: @csv, targets: { products: true }
      }.to change(Spree::Product, :count).by(23)
    end
  end
end
