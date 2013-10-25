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

  factory :import, class: Spree::Import do
    import_source_file

    trait :option do
      target "option"
      arguments %w[ color size ]
    end

    trait :property do
      target "property"
      arguments %w[ summary style_number ]
    end

    trait :prototype do
      target "prototype"
      arguments %w[ category ]
    end

    trait :product do
      target "product"
    end
  end
end
