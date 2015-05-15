# name: hipchat
# about: HipChat reporting for Discourse
# version: 1.0
# authors: antonin@binaryage.com
# url: https://github.com/binaryage/discourse-hipchat-plugin

require_relative './lib/hipchat'

after_initialize do
  
  on(:topic_created) do |topic, opts, user|
    next unless SiteSetting.hipchat_enabled
    HipChat::report_event!("created-topic", SiteSetting, user, topic)
  end

  on(:topic_destroyed) do |topic, user|
    next unless SiteSetting.hipchat_enabled
    HipChat::report_event!("deleted-topic", SiteSetting, user, topic)
  end

  on(:topic_recovered) do |topic, user|
    next unless SiteSetting.hipchat_enabled
    HipChat::report_event!("recovered-topic", SiteSetting, user, topic)
  end
  
  on(:post_created) do |post, opts, user|
    next unless SiteSetting.hipchat_enabled
    next if post.is_first_post?
    HipChat::report_event!("created-post", SiteSetting, user, post.topic, post)
  end

  on(:post_destroyed) do |post, opts, user|
    next unless SiteSetting.hipchat_enabled
    next if post.is_first_post?
    HipChat::report_event!("deleted-post", SiteSetting, user, post.topic, post)
  end

  on(:post_recovered) do |post, opts, user|
    next unless SiteSetting.hipchat_enabled
    next if post.is_first_post?
    HipChat::report_event!("recovered-post", SiteSetting, user, post.topic, post)
  end
  
end