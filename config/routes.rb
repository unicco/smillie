ActionController::Routing::Routes.draw do |map|
  map.resources :inquiries

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  map.connect "new", :controller => "parties", :action => "new"
  map.connect "create", :controller => "parties", :action => "create"
  map.connect "inquiries", :controller => "inquiries", :action => "new"
  map.connect "about", :controller => "home", :action => "about"
  map.connect "casestudy", :controller => "home", :action => "casestudy"
  map.connect "download", :controller => "home", :action => "download"
  map.connect "donation", :controller => "home", :action => "donation"

  map.resources :photos, :path_prefix => "/:party_key", :member => {:confirm_destroy => :get, :edit_thumbnail => :get}
  map.connect ":party_key/photos.xml", :controller => "photos", :action => "index", :format => "xml"
  map.connect ":party_key/zip", :controller => "photos", :action => "zip"
  map.connect ":party_key/info", :controller => "parties", :action => "info"
  map.connect ":party_key", :controller => "parties", :action => "show"

  # Install the default routes as the lowest priority.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
