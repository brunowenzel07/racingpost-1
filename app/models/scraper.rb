class Scraper < ActiveRecord::Base
  attr_accessor :date, :time, :course, :going, :distance, :pos, :draw, :horse_name, :country, :jockey, :trainer, :distance_behind, :total_dis_behind, :age, :weight, :or_data, :top_speed, :winning_time, :comment

  # def initialize(first_name, last_name)
  #   @first_name = first_name
  #   @last_name  = last_name
  # end

  # def as_xls(options = {})
  #   {
  #     date: date,
  #     time: time,
  #     course: course,
  #     going: going,
  #     distance: distance,
  #     pos: pos,
  #     draw: draw,
  #     horse_name: horse_name,
  #     country: country,
  #     jockey: jockey,
  #     trainer: trainer,
  #     distance_behind: distance_behind,
  #     total_dis_behind: total_dis_behind,
  #     age: age,
  #     weight: wt,
  #     or_data: or_data,
  #     top_speed: top_speed,
  #     winning_time: winning_time,
  #     comment: comment
  #   }
  # end
end
