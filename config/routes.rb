Spree::Core::Engine.routes.draw do
  get "/admin/products/export" => "admin/products#export", as: :admin_export_products
  namespace :admin do
    resources :imports
    resources :import_source_files
  end
end
