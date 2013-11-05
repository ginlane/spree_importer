require 'spec_helper'

describe SpreeImporter::Importers::StockItem do
  before :each do
    import_source_file = get_import_source_file "gin-lane-variant-export"
    import_source_file.import!
  end

  it "should import stock items in the proper quantity" do
    # TODO
  end

  it "should delete variants if nil"
end
