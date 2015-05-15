require 'net/http'
require "uri"

module HipChat

  def self.send_message_to_hipchat!(message, settings)
    raise "Please set hipchat_auth_token" if settings.hipchat_auth_token.blank?
    raise "Please set hipchat_room_id" if settings.hipchat_room_id.blank?

    params = {
      "auth_token" => settings.hipchat_auth_token,
      "room_id" => settings.hipchat_room_id,
      "from" => settings.hipchat_message_from or "Discourse",
      "color" => (settings.hipchat_message_color or "green"),
      "message_format" => "html",
      "message" => message
    }

    query_string = params.to_a.map { |x| "#{x[0]}="+URI.escape(x[1], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) }.join("&")

    url = "https://api.hipchat.com/v1/rooms/message?#{query_string}"
    Rails.logger.debug "HipChat request: " + url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path+"?"+uri.query)
    response = http.request(request)
    Rails.logger.debug "HipChat response: " + response.inspect
  end

  def self.report_event!(action, settings, user, topic, post=nil)
    begin
      Rails.logger.info "Report event to HipChat: #{user} #{action} #{topic} #{post}"
      category_markup = ""
      category_markup = "[#{topic.category.name}] " if topic.category
      user_markup = "<a href=\"#{Discourse.base_url}/users/#{user.username.downcase}\">#{user.username}</a>"
      topic_markup = "topic: <a href=\"#{topic.url}\">#{topic.title}</a>"

      if action=="created-topic" then
        send_message_to_hipchat! "#{category_markup}#{user_markup} started #{topic_markup}", settings
      elsif action=="recovered-topic" then
        send_message_to_hipchat! "#{category_markup}#{user_markup} recovered #{topic_markup}", settings
      elsif action=="deleted-topic" then
        send_message_to_hipchat! "#{category_markup}#{user_markup} deleted #{topic_markup}", settings
      elsif action=="created-post" then
        send_message_to_hipchat! "#{category_markup}#{user_markup} posted to #{topic_markup}", settings
      elsif action=="deleted-post" then
        send_message_to_hipchat! "#{category_markup}#{user_markup} deleted a post in #{topic_markup}", settings
      elsif action=="recovered-post" then
        send_message_to_hipchat! "#{category_markup}#{user_markup} recovered a post in #{topic_markup}", settings
      end
    rescue => e
      Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
    end
  end

end