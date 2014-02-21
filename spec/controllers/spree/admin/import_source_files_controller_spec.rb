require 'spec_helper'

describe Spree::Admin::ImportSourceFilesController do
  before :each do
    @user = FactoryGirl.create :admin_user
    controller.stubs(:spree_current_user).returns @user
  end

  it "should create a new impot source file, yo." do
    expect {
      spree_post :create, import_source_file: {
        data: fixture_file_upload("/files/simple-sheet-annotated.csv")
      }
    }.to change(Spree::ImportSourceFile, :count).by(1)
  end

  it "should return an error for invalid csv" do
    expect {
      spree_post :create, import: true, import_source_file: {
        data: fixture_file_upload("/files/gin-lane-product-list-invalid-date.csv")
      }
      response.should be_unprocessable
      JSON.parse(response.body)["errors"].first["message"].should =~ /Invalid date/
    }.to change(Spree::ImportSourceFile, :count).by(1)
  end

  it "should import from a spreadsheet url" do
    Spree::ImportSourceFile.any_instance.expects(:import_from_google!).with "TOKEN"
    controller.spree_current_user.stubs(:google_token).returns "TOKEN"
    spree_post :create_from_url, import_source_file: {
      spreadsheet_key: "KEY"
    }
  end

  context "import commands" do
    before :each do
      Spree::ImportSourceFile.any_instance.expects :import!
    end

    it "should create a new import source file and call #create!" do
      spree_post :create, import: true, import_source_file: {
        data: fixture_file_upload("/files/simple-sheet-annotated.csv")
      }
    end

    it "should call #import! on an import source file" do
      source_file = FactoryGirl.create :import_source_file
      spree_put :update, id: source_file.id
    end
  end
end
