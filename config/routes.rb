Whiteboard::Application.routes.draw do
  root :to => 'scheduler#index'

  match 'modal' => 'modal#modal', :via => :post

  match 'sandbox' => 'sandbox#index', :as => 'sandbox_index'

  # General pages
  match 'about' => 'home#about'
  match 'careers' => 'home#careers'
  match 'jobs' => 'home#careers'

  # Autocomplete routes
  match  'json/subject/all' => 'catalog#get_subjects'
  match  'json/subject/:subject_code/courses' => 'catalog#get_courses'
  match  'courses/search/auto/subject/:subject_code' => 'catalog#course_auto_search'
  match  'courses/search' => 'catalog#simple_search', :via => :post

  # Catalog routes
  match  'courses/' => 'catalog#semester', :as => 'show_university'
  match  'courses/:season/:year/' => 'catalog#semester', :as => 'show_semester'
  match  'courses/:season/:year/:subject_code' => 'catalog#subject', :as => 'show_subject'
  match  'courses/:season/:year/:subject_code/:course_number' => 'catalog#course', :as => 'show_course'


  # Professor routes
  match 'profs/' => 'profs#index', :as => 'profs_index'
  match 'profs/:name_slug' => 'profs#show', :as => 'show_prof'
  match 'professors/' => 'profs#index'
  match 'professors/:name_slug' => 'profs#show'

  # Temp hack to return json array of section ids
  match  'sections/' => 'catalog#sections', :via => :post

  # User auth routes
  match 'user/login' => 'user#login', :via => :post
  match 'user/register' => 'user#register', :via => :post
	match 'user/courses/remove' => 'user#remove_course', :via => :post  
	match 'user/logout', :as => 'logout'
  match 'user/refresh' => 'user#refresh', :via => :post	
  match 'user/header' => 'user#header', :via => :post

  # Scheduler routes
  match "scheduler/" => "scheduler#index", :as => "scheduler_index"
  match 'scheduler/move_section' => 'scheduler#move_section', :via => :post
	match 'scheduler/show/:id' => 'scheduler#show', :as => 'scheduler_show'
  match 'scheduler/save' => 'scheduler#save', :via => :post
  match 'scheduler/share' => 'scheduler#share', :via => :post
  match 'scheduler/register' => 'scheduler#register', :as => 'scheduler_register'
  match 'scheduler/download' => 'scheduler#download', :via => :post
  match 'scheduler/icalendar' => 'scheduler#icalendar', :via => :post
  match 'scheduler/configuration/change' => 'scheduler#change_configuration'
  match 'scheduler/schedule' => 'scheduler#schedule'
  match 'scheduler/courses/new' => 'scheduler#add_course', :via => :post, :as => :add_course
  match 'scheduler/courses/destroy' => 'scheduler#remove_course', :via => :post, :as => :remove_course

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
