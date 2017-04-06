module Scrapable
  extend ActiveSupport::Concern

  require 'mechanize'
  require 'awesome_print'

  def create_mechanize
    Mechanize.new { |agent|
      agent.user_agent_alias = 'Linux Firefox'
      # referer is the key since the newest Insta update as of May 25
      agent.request_headers = {"accept" => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8', "referer" => "http://google.com"}
      agent.redirect_ok = :all
      agent.follow_meta_refresh = true
    }
  end

  def cleanup_text text
    text.strip.gsub(/\n(\s)*/,'')
  end

  # container can be page or row...
  def get_data_from container, class_name
    if class_name.include?(".rp-horseTable__human__wrapper[data-prefix")
      res = container.css(class_name).first.children.text
    else
      res = container.css(class_name).children.text
    end
    cleanup_text res
  end

  def convert_fractions distance
    distance.gsub(/¼/, '.25').gsub(/½/, '.50').gsub(/¾/, '.75').to_f
  end

  def scrape url
    # begin
      runners = []
      count = 0
      create_mechanize.get(url) do |page|
        date = get_data_from(page, ".rp-raceTimeCourseName__date")
        time = get_data_from(page, ".rp-raceTimeCourseName__time")
        course = get_data_from(page, ".rp-raceTimeCourseName__name")
        going = get_data_from(page, ".rp-raceTimeCourseName_condition")
        distance = get_data_from(page, ".rp-raceTimeCourseName_distance")

        mainRow = page.css(".rp-horseTable__mainRow")
        mainRow.each do |row|
          pos = get_data_from(row, ".rp-horseTable__pos .rp-horseTable__pos__number")
          horse_name = get_data_from(row, ".rp-horseTable__horse__name")
          country = get_data_from(row, ".horseTable__horse__country")
          price = get_data_from(row, ".rp-horseTable__horse__price")
          jockey = get_data_from(row, ".rp-horseTable__human__wrapper[data-prefix='J:'] a")
          trainer = get_data_from(row, ".rp-horseTable__human__wrapper[data-prefix='T:']")

          # Draw and position
          draw_matched = pos.match(/\(.*\)/)
          draw = draw_matched.to_s.gsub(/[\(\)]/,'') if draw_matched
          pos = pos.gsub(/\(.*\)/, '').strip

          # Distances
          pos_lenth = row.css(".rp-horseTable__pos__length span")
          if pos_lenth.children.size == 0
            distance_behind  = 0
            total_dis_behind = 0
          elsif pos_lenth.children.size == 1
            distance_behind  = 0
            total_dis_behind = pos_lenth.first.children.text
          else
            distance_behind = pos_lenth.first.children.text
            distance_behind = convert_fractions distance_behind
            total_dis_behind = pos_lenth.last.children.text.gsub(/[\[\]]/,'')
            total_dis_behind = convert_fractions total_dis_behind
          end

          age = get_data_from(row, "[data-test-selector='horse-age']").to_i
          wt_st = get_data_from(row, "[data-test-selector='horse-weight-st']")
          wt_lb = get_data_from(row, "[data-test-selector='horse-weight-lb']")
          wt = "#{wt_st}-#{wt_lb}"

          # OR DATA
          or_data = get_data_from(row, "[data-ending='OR']")

          top_speed = get_data_from(row, "[data-test-selector='full-result-topspeed']")

          winning_time = get_data_from(page, ".rp-raceInfo__value:nth(2)")
          winning_time = winning_time[0..20]
          winning_time = cleanup_text winning_time

          comment_row = row.ancestors.css(".rp-horseTable__commentRow")
          comment = comment_row.css("[data-test-selector='text-comments'] td")[count].children.text
          comment = cleanup_text comment
          comment.gsub!("                            ", ' ')

          runners <<

            Scraper.new({
            count: count + 1,
            date: date,
            time: time,
            course: course,
            going: going,
            distance: distance,
            pos: pos,
            draw: draw,
            horse_name: horse_name,
            country: country,
            jockey: jockey,
            trainer: trainer,
            distance_behind: distance_behind,
            total_dis_behind: total_dis_behind,
            age: age,
            weight: wt,
            or_data: or_data,
            top_speed: top_speed,
            winning_time: winning_time,
            comment: comment
            })

          count += 1
        end

        return runners
      end
    # rescue => e
    #   if e.class == Mechanize::ResponseCodeError && e.response_code == "404"
    #     p "--- error: #{e.inspect}, continuing..."
    #   end
    # end
  end
end