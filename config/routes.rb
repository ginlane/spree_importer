Spree::Core::Engine.routes.draw do
  get "/admin/products/export" => "admin/products#export", as: :admin_export_products
  namespace :admin do
    resources :imports
    resources :import_source_files do
      put  :edit_in_google
      post :import_from_google
      get  :show_in_google
    end
    get "/auth/google" => "oauth#google", as: :google_auth
    get "/auth/google_redirect" => "oauth#google_redirect"
  end
end
