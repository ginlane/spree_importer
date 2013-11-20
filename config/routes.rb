Spree::Core::Engine.routes.prepend do
  get "/admin/products/export" => "admin/products#export", as: :admin_export_products
  get "/admin/orders/export"   => "admin/orders#export", as: :admin_export_orders

  namespace :admin do
    resources :imports
    resources :import_source_files
  end
end
