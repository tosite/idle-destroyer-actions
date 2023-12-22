require '/actions/initializer'

client = GitHubApiClient.new(base_url: GITHUB_BASE_URL, token: TOKEN, ignore_labels: IGNORE_LABELS)
targets = client.fetch_old_issues_and_pulls(limit: LIMIT)

closed_issues = []
closed_pulls = []
targets.each do|target|
  res = client.close(target)
  next if res != 200
  if target[:is_pr]
    closed_pulls << target
  else
    closed_issues << target
  end
end

issues = closed_issues.map { "<#{_1[:url]}|#{_1[:title]}> - #{_1[:dates_not_updated]} days ago"}
pulls = closed_pulls.map { "<#{_1[:url]}|#{_1[:title]}> - #{_1[:dates_not_updated]} days ago"}

SlackClient.new(webhook_url: SLACK_WEBHOOK_URL).send_slack_message(CLOSED_TEMPLATE, issues, pulls)
