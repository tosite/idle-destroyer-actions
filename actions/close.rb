require '/actions/initializer'

client = GitHubApiClient.new(base_url: GITHUB_BASE_URL, token: TOKEN, ignore_labels: IGNORE_LABELS)
targets = client.fetch_old_issues_and_pulls(limit: LIMIT)

closed_issues = []
closed_pulls = []
targets.each do|target|
  # res = client.close(target)
  # next if res != 200
  if target[:is_pr]
    closed_pulls << target
  else
    closed_issues << target
  end
end

SlackClient.new(webhook_url: SLACK_WEBHOOK_URL).send_slack_message(CLOSED_TEMPLATE, closed_issues, closed_pulls)
