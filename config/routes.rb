Spree::Core::Engine.routes.prepend do
  get "/admin/products/export" => "admin/products#export", as: :admin_export_products
  get "/admin/orders/export"   => "admin/orders#export", as: :admin_export_orders

  namespace :admin do
    resources :imports
    resources :import_source_files do
      put  :edit_in_google
      post :create_from_url, on: :collection
      post :import_from_google
      get  :show_in_google
    end
    get "/auth/check_google" => "oauth#check_google", as: :check_google
    get "/auth/google" => "oauth#google", as: :google_auth
    get "/auth/google_redirect" => "oauth#google_redirect"
  end
end
