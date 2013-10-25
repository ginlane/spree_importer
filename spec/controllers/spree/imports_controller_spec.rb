require 'spec_helper'

describe Spree::ImportsController do
  before :each do
    @file = FactoryGirl.create :import_source_file
  end

  def attrs(target)
    attributes      = FactoryGirl.build(:import, target, import_source_file_id: @file.id).attributes
    attributes.slice *%w[ import_source_file_id target arguments ]
  end

  it "should import options from spreadsheet" do
    expect {
      spree_post :create, import: attrs(:option)
    }.to change(Spree::OptionType, :count).by(2)
  end

  it "should import properties from spreadsheet" do
    expect {
      spree_post :create, import: attrs(:property)
    }.to change(Spree::Property, :count).by(2)
  end

  it "should import protoypes from spreadsheet" do
    expect {
      spree_post :create, import: attrs(:prototype)
    }.to change(Spree::Prototype, :count).by(4)
  end

  context "with a populated db" do
    before :each do
      shipping     = FactoryGirl.create :shipping_category, name: "Default"

      base         = importer "bauble-bar"

      summary      = base.import :property, property_name: "summary"
      style_number = base.import :property, property_name: "style_number"
      color        = base.import :option, option_name: "color"

      [ summary, style_number, color ].each &:save!

      prototypes    = base.import :prototype, prototype_name: :category, create_record: true
    end

    it "should import products from spreadsheet" do
      expect {
        spree_post :create, import: attrs(:product)
      }.to change(Spree::Product, :count).by(37)
    end
  end
end
