Trend::Application.routes.draw do

  resources :weekly_trends

  resources :daily_trends

  resources :daily_timelines
  
  #match "sitemap.xml" => "sitemap/sitemap"
                                                  
  resources :pages do
    member do 
      get 'csv'
    end
    collection do 
      get 'auto_complete_for_search_query'
    end
  end

  # map.connect '/pages/auto_complete_for_search_query', :controller => 'pages', :action => 'auto_complete_for_search_query'
  # map.connect '/pages/:url', :controller => 'pages', :action => 'find_by_url',
  #                                               :url => /.*/
  # map.connect '/pages', :controller => 'pages', :action => 'index'                                       
  resources :widgets do
    member do 
      get 'chart_widget'
    end
  end
  match  '/info/auto_complete_for_search_query' =>  'pages#auto_complete_for_search_query'
  resources :widgets do
    member do 
      get 'about'
      get 'contact'
      get 'frames'
      get 'finance'
      get 'people'
    end
  end


  match '/' => 'pages#index'
  root  :to => 'pages#index'
end
