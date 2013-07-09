class PagesController < ApplicationController
  # GET /pages
  protect_from_forgery :only => [:create, :update, :destroy]
  layout 'pages'#, :except => [:auto_complete_for_search_query]
  use_google_charts

  caches_page :show
  caches_page :csv  
  
  def auto_complete_for_search_query
    # look for autosuggest results in memcached
    unless read_fragment({:query => params["search"]["query"]}) 
      @pages = Page.title_like params["search"]["query"]
    end
    render :partial => "search_results"
  end  
    
  def index
    unless params[:date]
      params[:date]='2013-06-30'
    end  
    # monthly trends 
    @monthlytrend= MonthlyTrend.find(:all, :limit => APP_CONFIG['articles_per_page'] , :order => 'trend DESC', :conditions => ["date = ? and page_id NOT IN (?) and page_id NOT IN (select page_id from featured_pages)", params[:date], APP_CONFIG['blacklist']])
    @pages =[]
    @monthlytrend.each do |mt|
      @pages << mt.page
    end  
    # random rising, rotates
    @page = DailyTrend.find(:all, :limit => APP_CONFIG['articles_per_page'] , :order => 'trend DESC', :conditions => ["date = ? and page_id NOT IN (?) and page_id NOT IN (select page_id from featured_pages)", params[:date], APP_CONFIG['blacklist']] ).sample.page  
      
    unless params[:page]
      params[:page]='1'
    end  
      
    respond_to do |format|
      format.html # index.html.erb
    end      
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
#### Custom REST actions #######  
  
  # GET /pages/1/csv
  def csv
    @page = Page.find(params[:id]) 
    csv_array = ["Date,Pageviews"]
    @page.daily_page_views.each do |dpv|
      csv_array << "#{dpv.date},#{dpv.pageviews}"
    end
    send_data csv_array.join("\n"), :type => 'text/csv; charset=utf-8', :filename=>"#{@page.url}.csv",
    :disposition => 'attachment'
  end  

end
