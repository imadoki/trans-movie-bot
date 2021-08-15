# frozen_string_literal: true

require './lib/slack_client'
require './lib/workers/trans_mp4_worker'

module EventCallback
  # FIXME: fix rubocop warning
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.run(data)
    puts data

    res = SlackClient.auth_test
    raise 'bot infomation is not found.' unless res['ok']

    bot_user_id = res['user_id']

    raise NotImplementedError if data['event']['type'] != 'message' || data['event']['channel_type'] != 'im'

    return if data.dig('event', 'user') == bot_user_id

    if data.dig('event', 'files') && data.dig('event', 'subtype') == 'file_share'
      channel = data['event']['channel']
      url = data.dig('event', 'files', 0, 'url_private_download')
      TransMp4Worker.perform_async(channel, url)
      SlackClient.post_message(channel: channel, text: 'enqueue')
      nil
    else
      SlackClient.post_message(channel: data['event']['channel'],
                               text: 'はろー')
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
