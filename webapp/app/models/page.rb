class Page < ActiveRecord::Base
  has_many :daily_timelines
  has_one :daily_trend
  has_one :monthly_trend 
  has_many :daily_page_views, :order => "date" 
  
  BOSSMan.application_id = APP_CONFIG['yahoo_boss_id']
    
  def normed_daily_pageviews(on_date, range=30)
    logger.debug("Date = #{on_date}")
    timeline = self.daily_timelines.where("on_date = ?", on_date).first
    @pageviews = timeline.pageviews.split("\002").map{ |x| x.to_i }
    @dates = timeline.dates.split("\002")    
    date_view_hash = {}
    logger.debug("#{@dates.inspect}")
        
      @dates.each_with_index do |date, index|
      date_view_hash[date] = @pageviews[index]
    end
    logger.debug("#{date_view_hash.inspect}")
    sorted_pageviews = []
    date_view_hash.keys.sort.each { |key| sorted_pageviews << date_view_hash[key] }
    range = sorted_pageviews.length
    maxval = sorted_pageviews[-range,range].max
    normed_values = sorted_pageviews[-range,range].collect { |x| x * (110.0 / maxval)}    
    return normed_values
  end

  def find_total_pageviews(on_date)
    timeline = self.daily_timelines.where("on_date = ?", on_date).first
    @pageviews = timeline.pageviews.split("\002").map{ |x| x.to_i }
    return @pageviews.inject(0,:+)
  end
   
  def linechart( on_date, fillcolor='8fc800', range=30)
    dataset = GC4R::API::GoogleChartDataset.new :data => self.normed_daily_pageviews(on_date,range), 
      :color => '888888', :fill => ['B', fillcolor ,'0','0','0']
    # red => FF0000
    # lightblue => 76A4FB
    # green => 33FF00
    # darkblue => 0000FF    
    data = GC4R::API::GoogleChartData.new :datasets => dataset , :min => 0, :max => 120
    # @chart = GoogleBarChart.new :width => 120, :height => 12
    @chart = GC4R::API::GoogleLineChart.new :width => 620, :height => 280
    @chart.data = data
    return @chart
  end  
  
  def sparkline( on_date, fillcolor='8fc800', range=30)
    dataset = GC4R::API::GoogleChartDataset.new :data => self.normed_daily_pageviews(on_date,range), 
      :color => '888888', :fill => ['B', fillcolor ,'0','0','0']
    # red => FF0000
    # lightblue => 76A4FB
    # green => 33FF00
    # darkblue => 0000FF    
    data = GC4R::API::GoogleChartData.new :datasets => dataset , :min => 0, :max => 120
    # @chart = GoogleBarChart.new :width => 120, :height => 12
    @chart = GC4R::API::GoogleSparklinesChart.new :width => 120, :height => 15
    @chart.data = data
    return @chart
  end  
   
  
  def sorted_dates(on_date)
   timeline = self.daily_timelines.where("on_date = ?", on_date).first
   rawdates = timeline.dates.split("\002")
   @data = []
   rawdates.each do |date|
     @data << DateTime.strptime( date.to_s, "%Y%m%d")
   end
   @data.sort
 end  
  
  
 def date_pageview_array(on_date)
    timeline = self.daily_timelines.where("on_date = ?", on_date).first
    rawdates = timeline.dates.split("\002")
    pageviews = timeline.pageviews.split("\002").map{ |x| x.to_i }    
    @data = []
    rawdates.each_with_index do |date, index|
      @data << [DateTime.strptime( date.to_s, "%Y%m%d").strftime('%D'), pageviews[index]]
    end
   return @data
 end
  
  
  def timeline(on_date)
    timeline = self.daily_timelines.where("on_date = ?", on_date).first
    rawdates = timeline.dates.split("\002")
    pageviews = timeline.pageviews.split("\002").map{ |x| x.to_i }
        
    @data ={}
    rawdates.each_with_index do |date, index|
      @data[DateTime.strptime( date.to_s, "%Y%m%d")] = {:wikipedia_page_views => pageviews[index]}
    end
    return @data
  end

  def sorted_dates_old
  @data = []
  self.daily_page_views.each do |dpv|
    @data << DateTime.strptime( dpv.date.to_s, "%Y%m%d")
  end
  @data.sort
  end 

  def date_pageview_array_old
   @data = []
   self.daily_page_views.each do |dpv|
     @data << [DateTime.strptime( dpv.date.to_s, "%Y%m%d").strftime('%D'), dpv.pageviews]
   end
   return @data
 end
 
def timeline_old
  @data ={}
  self.daily_page_views.each do |dpv|
    @data[DateTime.strptime( dpv.date.to_s, "%Y%m%d")] = {:wikipedia_page_views => dpv.pageviews}
  end
  return @data
end

def normed_daily_pageviews_old( range=30)
  date_view_hash = {}
  self.daily_page_views.each do |dpv|
    date_view_hash[dpv.date] = dpv.pageviews
  end
  logger.debug("#{date_view_hash.inspect}")
  sorted_pageviews = []
  date_view_hash.keys.sort.each { |key| sorted_pageviews << date_view_hash[key] }
  logger.debug("#{sorted_pageviews.inspect}")
  maxval = sorted_pageviews[-range,range].max
  normed_values = sorted_pageviews[-range,range].collect { |x| x * (110.0 / maxval)}    
  return normed_values
end

end
