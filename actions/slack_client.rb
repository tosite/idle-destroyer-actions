class SlackClient
  @webhook_url = ''

  def initialize(webhook_url:)
    @webhook_url = webhook_url
  end

  def build_message(template, issues, pulls)
    issue_link = issues.map { "<#{_1[:url]}|#{_1[:title]}>" }.join("\n")
    pull_link = pulls.map { "<#{_1[:url]}|#{_1[:title]}>" }.join("\n")
    t = template.gsub(/%ISSUES%/, issue_link)
    t.gsub!(/%PULLS%/, pull_link)
    t
  end

  def send_slack_message(template, issues, pulls)

    payload = {
      "text": "Result: :apple:",
      "blocks": [],
      "attachments": [
        {
          "color": "#00FF00",
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

    conn = Faraday.new(url: @webhook_url)
    response = conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json
    end

    pp response.body
    if response.success?
      puts 'Slack message sent successfully!'
    else
      puts 'Failed to send Slack message.'
    end
  end

end
