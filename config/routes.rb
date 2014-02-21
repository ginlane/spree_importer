Spree::Core::Engine.add_routes do
  get "/admin/products_export" => "admin/products#export", as: :admin_export_products
  get "/admin/orders_export"   => "admin/orders#export", as: :admin_export_orders

  namespace :admin do
    resources :imports
    resources :import_source_files do
      get  :edit_in_google
      post :create_from_url, on: :collection
      get :import_from_google
      get  :show_in_google
      get  :export_to_google
      get :create_google, on: :collection
    end
    get "/auth/check_google" => "oauth#check_google", as: :check_google
    get "/auth/google" => "oauth#google", as: :google_auth
    get "/auth/google_redirect" => "oauth#google_redirect"
  end
end
