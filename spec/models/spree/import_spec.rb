require 'spec_helper'

describe Spree::Import do
  it "should order all list fields before save" do
    csv    = Spree::ImportSourceFile.new data: "fnord", mime: "text/csv"
    csv.save!
    import = Spree::Import.new import_source_file: csv, target: "property", arguments: %w[ summary style_number fish_sauce ]
    import.save.should be_true
    import.arguments.should == %w[ fish_sauce style_number summary ]
  end
end
