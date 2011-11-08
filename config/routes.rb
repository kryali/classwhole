Whiteboard::Application.routes.draw do

  get "scheduler/index"
  get "scheduler/show"
  get "scheduler/new"
  get "scheduler/renderTest"

  match  'courses/search/auto/subject' => 'catalog#subject_auto_search'
  match  'courses/search/auto/subject/:subject_code' => 'catalog#course_auto_search'
  match  'courses/search' => 'catalog#simple_search', :via => :post

  match  'courses/' => 'catalog#semester', :as => 'show_university'
  match  'courses/:season/:year/' => 'catalog#semester', :as => 'show_semester'
  match  'courses/:season/:year/:subject_code' => 'catalog#subject', :as => 'show_subject'
  match  'courses/:season/:year/:subject_code/:course_number' => 'catalog#course', :as => 'show_course'

  root :to => 'home#index'
  match 'user/login' => 'user#login', :via => :post
  match 'user/register' => 'user#register', :via => :post
  match 'user/courses/new' => 'user#add_course', :via => :post, :as => :add_course
  match 'user/courses/destroy/:course_id' => 'user#remove_course', :as => :remove_course
	match 'user/courses/remove' => 'user#remove_course', :via => :post  
	match 'user/logout', :as => 'logout'
	
  match 'scheduler/move_section' => 'scheduler#move_section', :via => :post
  match 'scheduler/paginate' => 'scheduler#paginate', :via => :post
	match 'scheduler/new' => 'scheduler#new'
	match 'scheduler/show/:id' => 'scheduler#show', :as => 'scheduler_show'
  match 'scheduler/save' => 'scheduler#save', :via => :post
  match 'scheduler/share' => 'scheduler#share', :via => :get
  match 'scheduler/register' => 'scheduler#register', :as => 'scheduler_register'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
