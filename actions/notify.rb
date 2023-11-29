require '/actions/initializer'

client = GitHubApiClient.new(base_url: GITHUB_BASE_URL, token: TOKEN, ignore_labels: IGNORE_LABELS)
targets = client.fetch_old_issues_and_pulls(limit: LIMIT)
issues = targets.select { !_1[:is_pr] }.map { "<#{_1[:url]}|#{_1[:title]}> - #{_1[:dates_not_updated]} days ago"}
pulls = targets.select { _1[:is_pr] }.map { "<#{_1[:url]}|#{_1[:title]}> - #{_1[:dates_not_updated]} days ago"}

puts '===================================='
pp targets
puts '===================================='

SlackClient.new(webhook_url: SLACK_WEBHOOK_URL).send_slack_message(NOTIFY_TEMPLATE, issues, pulls)
