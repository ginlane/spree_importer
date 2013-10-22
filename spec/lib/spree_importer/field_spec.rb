require 'spec_helper'

describe SpreeImporter::Field do
  it "should sanitize fields with options in parens" do
    field = SpreeImporter::Field.new "Fnord Poops(23skidoo)"
    field.index.should be_nil
    field.sanitized.should eql "fnord_poops"
    field.raw.should == "Fnord Poops(23skidoo)"
    field.option.should == "23skidoo"
    field.option?.should be_true
  end

  it "should just do normal shiz with normal shiz" do
    field = SpreeImporter::Field.new "Fnord Poops"
    field.sanitized.should eql "fnord_poops"
  end

  it "should have hash/uniq equality" do
    field1 = SpreeImporter::Field.new "Fnord Poops"
    field2 = SpreeImporter::Field.new "Fnord Poops"
    field3 = SpreeImporter::Field.new "Fnord Poops(23skidoo)"
    [ field1, field2, field3 ].uniq.length.should eql 2
  end
end
