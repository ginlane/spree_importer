require 'spec_helper'

describe Spree::ImportsController do
  before :each do
    @csv = fixture_file_upload "/files/bauble-bar.csv", "text/csv"
  end
  it "should import category arguments from passed spreadsheet" do
    spree_post :create, import: @csv
  end
end
