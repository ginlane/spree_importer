require 'spec_helper'

describe Spree::ImportSourceFile do
  it "should return a csv file" do
    source_file = Spree::ImportSourceFile.new data: "col1,col2,col3", mime: "text/csv"
    source_file.csv?.should be_true
  end
end
