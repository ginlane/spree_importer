require 'spec_helper'

describe Spree::Admin::ImportSourceFilesController do
  it "should create a new impot source file, yo." do
    expect {
      spree_post :create, import_source_file: {
        data: fixture_file_upload("/files/simple-sheet-annotated.csv")
      }
    }.to change(Spree::ImportSourceFile, :count).by(1)
  end
  context "import commands" do
    before :each do
      Spree::ImportSourceFile.any_instance.expects :import!
    end
    it "should create a new import source file and call #create!" do
      expect {
        spree_post :create, import: true, import_source_file: {
          data: fixture_file_upload("/files/simple-sheet-annotated.csv")
        }
      }.to change(Spree::ImportSourceFile, :count).by(1)
    end

    it "should call #import! on an import source file" do
      source_file = FactoryGirl.create :import_source_file
      spree_put :update, id: source_file.id
    end
  end
end
