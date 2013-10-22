require 'spec_helper'

describe SpreeImporter::Importers::Option do

  it "should set attributes on options from csv file" do
    base        = importer "bauble-bar"
    option_type = base.import :option, option_name: "Color", delimiter: ","

    option_type.option_values.length.should eql 33
  end

end
