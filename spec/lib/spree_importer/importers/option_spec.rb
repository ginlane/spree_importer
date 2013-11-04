require 'spec_helper'

describe SpreeImporter::Importers::Option do
  it "should not be row based" do
    SpreeImporter::Importers::Option.row_based?.should be_false
  end
  it "should set attributes on options from csv file" do
    base        = get_importer "gin-lane-product-list"
    option_type = base.import :option, option_name: "color", delimiter: ","
    option_type.option_values.length.should eql 4
  end

  it "should create records if create_record is true" do
    base        = get_importer "gin-lane-product-list"
    option_type = base.import :option, option_name: "color", delimiter: ",", create_record: true
    option_type.option_values.length.should eql 4
    option_type.new_record?.should be_false
  end

  it "should warn about dups" do
    option_importer = SpreeImporter::Importers::Option.new
    option_type     = FactoryGirl.create :option_type, name: "fnord", presentation: "FNORD"
    instance        = option_importer.fetch_instance name: "fnord"
    instance.id.should eql option_type.id
    option_importer.warnings.first.should match /Warning/
  end
end
