require 'spec_helper'

describe SpreeImporter::Importers::Variant do
  it 'should set :batch_id on instances' do
    import_source_file = get_import_source_file "gin-lane-variant-export"
    import_source_file.import!
    master         = Spree::Variant.find_by_sku "STN-FW13-DUMMY-NO-SIZE"
    master.batch_id.should == 999
    master.product.variants.each do |v|
      v.batch_id.should == 999
    end
  end

  it "should import stock items in the proper quantity" do
    import_source_file = get_import_source_file "gin-lane-variant-export"
    import_source_file.import!
    variant         = Spree::Variant.find_by_sku "STN-FW13-DUMMY-NO-SIZE"
    variant.should be_is_master

    variants        = variant.product.variants

    # binding.pry
    variants.length.should eql 4

    counts          = variants.map(&:stock_items).flatten.map &:count_on_hand
    expected_counts = [ 0, 1, 32, 3 ]

    (expected_counts & counts).should eql expected_counts
  end

  it "shouldn't disassociate variants to option values" do
    import_source_file = get_import_source_file "ayr-initial-import"
    import_source_file.import!

    master             = Spree::Variant.find_by_sku "13942-BLC11"
    variant            = master.product.variants.first
    var_sku            = variant.sku
    opt_vals           = variant.option_values.to_a

    exporter           = SpreeImporter::Exporter.new variants: true
    import_source_file = Spree::ImportSourceFile.new data: exporter.export
    import_source_file.import!

    var_check          = Spree::Variant.find_by_sku var_sku
    var_check.option_values.to_a.should eql opt_vals
  end
end
