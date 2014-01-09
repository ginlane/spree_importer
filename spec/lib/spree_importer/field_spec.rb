require 'spec_helper'

describe SpreeImporter::Field do
  it "should sanitize fields with options in parens" do
    field = SpreeImporter::Field.new "Fnord Poops(23skidoo)"
    field.index.should be_nil
    field.sanitized.should eql "fnord-poops"
    field.raw.should == "Fnord Poops(23skidoo)"
    field.option.should == "23skidoo"
    field.option?.should be_true
  end

  it "should just do normal shiz with normal shiz" do
    field = SpreeImporter::Field.new "Fnord Poops"
    field.sanitized.should eql "fnord-poops"
  end

  it "should have hash/uniq equality" do
    field1 = SpreeImporter::Field.new "Fnord Poops"
    field2 = SpreeImporter::Field.new "Fnord Poops"
    field3 = SpreeImporter::Field.new "Fnord Poops(23skidoo)"
    [ field1, field2, field3 ].uniq.length.should eql 2
  end

  it "should handle header columns and [kind] prefixes" do
    field = SpreeImporter::Field.new "[option] fnord", header: true
    field.kind.should eql "option"
    field.sanitized.should eql "fnord"
    field.raw.should eql "[option] fnord"
    field.option.should be_nil
    field.header?.should be_true
    field.kind?.should be_true
  end

  it "should generate a [kind]name(option) field" do
    str   = SpreeImporter::Field.to_field_string "Motherlicker", kind: "old", option: "gregg"
    field = SpreeImporter::Field.new str, header: true

    str.should eql "[old](gregg)Motherlicker"
    field.kind.should eql "old"
    field.option.should eql "gregg"
    field.sanitized.should eql "motherlicker"
    field.label.should eql "Motherlicker"
    field.to_s.should eql str
  end

  it "should match regexps" do
    field  = SpreeImporter::Field.new "[kind](option)Label"
    (field =~ /option/).should be_true
    field.should match(/option/)
  end
end
