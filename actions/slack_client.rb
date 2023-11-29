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
    t = template.gsub(/%ISSUES%/, issue_link)
    t.gsub!(/%PULLS%/, pull_link)
    t
  end

  def send_slack_message(template, issues, pulls)
    payload = {
      "text": "Result: :apple:",
      "attachments": [
        {
          "color": "#88D8B0",
          "blocks": [
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": build_message(template, issues, pulls)
              }
            }
          ]
        }
      ]
    }

    puts '---- message -------------------'
    pp payload
    puts '--------------------------------'

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
