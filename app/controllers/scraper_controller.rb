class ScraperController < ApplicationController
  include Scrapable

  def show
  end

  def extract
    @runners = scrape(params["scraper"]["url"])

    col_names = [:count, :date, :time, :course, :going, :distance, :pos, :draw, :horse_name, :country, :jockey, :trainer, :distance_behind, :total_dis_behind, :age, :weight, :or_data, :top_speed, :winning_time, :comment]
    send_data @runners.to_xls(:columns => col_names, headers: col_names.map(&:to_s)), filename: 'runners.xls'
  end
end
