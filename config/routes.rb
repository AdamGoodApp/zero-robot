require 'api_constraints'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  root 'robot#dashboard'

  get 'dashboard', to: 'robot#dashboard'
  get 'viewer', to: 'robot#viewer'
  get 'expert_dashboard', to: 'robot#expert_dashboard'

  get 'setup', to: 'application#setup'

  devise_scope :user do
    scope :token do
      put 'add', to: 'users/registrations#add_token', as: 'token_add'
      delete 'remove/:id', to: 'users/registrations#remove_token', as: 'token_remove'
    end
  end

  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      # Waypoints
      resources :waypoints
      match '/waypoint/move-from-robot' => 'waypoints#move_from_robot', :via => :post
      match '/waypoint/move-along-axis' => 'waypoints#move_along_axis', :via => :post
      match '/waypoint/move-to-point' => 'waypoints#move_to_point', :via => :post

      # Robot api
      resources :robots, :except => [:new, :show, :edit, :destroy]
      match '/robot/iksolver' => 'robot#iksolver', :via => :post
      match '/robot/move' => 'robot#robot_move', :via => :post
      match '/robot/go-home' => 'robot#robot_go_home', :via => :post
      match '/robot/rotate-joints' => 'robot#rotate_joints', :via => :post
      match '/robot/on' => 'robot#robot_on', :via => :post
      match '/robot/off' => 'robot#robot_off', :via => :post
      match '/robot/current-pose' => 'robot#current_pose', :via => :get
      match '/robot/create-home' => 'robot#create_home', :via => :post
      match '/robot/home-pose' => 'robot#home_pose', :via => :get

      # Segments api
      resource :segments
      match '/toolpath/segment/sort' => 'segments#sort', :via => :post

      # Toolpath api
      resource :toolpaths
      match 'segments/segment-waypoints' => 'segments#segment_waypoints', :via => :get
      match 'segments/add-waypoint' => 'segments#add_waypoint', :via => :put
      match 'toolpaths/build-trajectory' => 'toolpaths#build_trajectory', :via => :get
      match 'toolpaths/calc-trajectory' => 'toolpaths#calc_without_toolpath', :via => :get
      match 'toolpaths/share' => 'toolpaths#share', :via => :post
    end
  end
end
