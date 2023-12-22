class SlackClient
  @webhook_url = ''

  def initialize(webhook_url:)
    @webhook_url = webhook_url
  end

  def build_message(template, issues, pulls)
    puts '---- issues --------------------'
    issue_link = issues.empty? ? 'Noting' : issues.join("\n")
    pp issue_link
    puts '---- pulls ---------------------'
    pull_link = pulls.empty? ? 'Noting' : pulls.join("\n")
    pp pull_link
    puts '--------------------------------'
    template.gsub(/%ISSUES%/, issue_link)
            .gsub(/%PULLS%/, pull_link)
            .gsub(/%LIMIT%/, ENV['LIMIT_DAYS'])
            .gsub(/%IGNORE_LABELS%/, IGNORE_LABELS.join(', '))
  end

  def send_slack_message(template, issues, pulls)
    payload = {
      "attachments": [
        {
          "mrkdwn_in": ["text"],
          "color": "warning",
          "text": build_message(template, issues, pulls),
          "parse": 'none',
          "as_user": true,
          "footer": "https://github.com/tosite/idle-destroyer-actions",
        }
      ]
    }

    conn = Faraday.new(url: @webhook_url)
    response = conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json
    end

    if response.success?
      puts 'Slack message sent successfully!'
    else
      raise "Failed to send Slack message.(#{response.body})"
    end
  end
end
