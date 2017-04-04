class ScraperController < ApplicationController
  include Scrapable

  def show
  end

  def extract
    @runners = scrape(params["scraper"]["url"])

    send_data @runners.to_xls(:columns => [:date, :time, :course, :going, :distance, :pos, :draw, :horse_name, :country, :jockey, :trainer, :distance_behind, :total_dis_behind, :age, :weight, :or_data, :top_speed, :winning_time, :comment]), filename: 'runners.xls'
    # users_path(request.parameters.merge({:format => :xls}))
  end
end
