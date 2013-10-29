FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_importer/factories'

  factory :import_source_file, class: Spree::ImportSourceFile do
    mime "text/csv"
    data {
      File.read "#{SpreeImporter::Engine.root}/spec/fixtures/files/bauble-bar.csv"
    }
    trait :annotated do
      data {
        File.read "#{SpreeImporter::Engine.root}/spec/fixtures/files/simple-sheet-annotated.csv"
      }
    end
  end
end
