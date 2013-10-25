Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :imports
    resources :import_source_files
  end
end
