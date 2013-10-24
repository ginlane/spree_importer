require 'spec_helper'

describe Spree::Import do
  it "should order all list fields before save" do
    import = Spree::Import.create import_source_file_attributes: { data: "fnord", mime: "text/csv" },
                                  target: "property", arguments: %w[ summary style_number fish_sauce ]

    import.save.should be_true
    import.arguments.should == %w[ fish_sauce style_number summary ]
  end
end
