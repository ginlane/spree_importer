require 'spec_helper'

describe SpreeImporter::Importers::Variant do
  before :each do
    import_source_file = get_import_source_file "gin-lane-variant-export"
    import_source_file.import!
  end

  it "should import stock items in the proper quantity" do
    variant         = Spree::Variant.find_by_sku "STN-FW13-DUMMY-NO-SIZE"
    variant.should be_is_master

    variants        = variant.product.variants

    variants.length.should eql 4

    counts          = variants.map(&:stock_items).flatten.map &:count_on_hand
    expected_counts = [ 0, 1, 32, 3 ]

    (expected_counts & counts).should eql expected_counts
  end
end
