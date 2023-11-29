class SlackClient
  @webhook_url = ''

  def initialize(webhook_url:)
    @webhook_url = webhook_url
  end

  def build_message(template, issues, pulls)
    issue_link = issues.empty? ? 'Noting' : issues.map { "<#{_1[:url]}|#{_1[:title]}>" }.join("\n")
    pull_link = pulls.empty? ? 'Noting' : pulls.map { "<#{_1[:url]}|#{_1[:title]}>" }.join("\n")
    puts '---- issues --------------------'
    pp issues
    pp issue_link
    puts '---- pulls ---------------------'
    pp pulls
    pp pull_link
    puts '--------------------------------'
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

    # conn = Faraday.new(url: @webhook_url)
    # response = conn.post do |req|
    #   req.headers['Content-Type'] = 'application/json'
    #   req.body = payload.to_json
    # end
    #
    # if response.success?
      puts 'Slack message sent successfully!'
    # else
    #   raise "Failed to send Slack message.(#{response.body})"
    # end
  end
end
