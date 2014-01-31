require 'spec_helper'

describe SpreeImporter::Importers::Variant do
  before :each do
    import_source_file = get_import_source_file "gin-lane-product-list"
    import_source_file.import!
  end

  it "should import taxonz" do
    Spree::Taxonomy.count.should eql 4
    hatz = Spree::Taxonomy.find_by_name "Hat"
    hatz.root.name.should == "Hat"
    subs  = hatz.root.children
    names = %w[ SUBHAT UBERHAT ]
    (subs.map(&:name) & names).should eql names
  end
  it "should assign taxonomy_id" do
    Spree::Taxonomy.count.should eql 4
    hatz = Spree::Taxonomy.find_by_name "Hat"
    hatz.root.name.should == "Hat"
    subs  = hatz.root.children
    subs.each do |t|
      t.taxonomy_id.should == hatz.id
    end
  end  
end
