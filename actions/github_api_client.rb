class GitHubApiClient
  @base_url = ''
  @ignore_labels = []
  @headers = {}

  def initialize(base_url:, token:, ignore_labels:)
    @base_url = base_url
    @token = token
    @ignore_labels = ignore_labels
    @headers = {
      'Authorization' => "Bearer #{token}",
      'Accept' => 'application/vnd.github.v3+json'
    }
  end

  def conn
    @conn = @conn || Faraday.new(url: @base_url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  def fetch_old_issues_and_pulls(limit:)
    page = 1
    old_issues = []
    puts "REQUEST URL: #{@base_url}/issues"
    loop do
      response = conn.get('issues', { state: 'open', per_page: 100, page: page }, @headers)
      issues = JSON.parse(response.body)
      break if response.status != 200 || issues.empty?
      old_issues << issues.select { |issue| issue['updated_at'] < limit && !issue['labels'].any? { |label| @ignore_labels.include?(label['name']) } }
      page += 1
    end
    compressed_response(old_issues.flatten)
  end

  def close(row)
    uri = row[:is_pr] ? "pulls/#{row[:number]}" : "issues/#{row[:number]}"
    puts "REQUEST URL: #{@base_url}/#{uri}"
    res = conn.patch(uri, { state: 'closed' }.to_json, @headers)
    res.status
  end

  private

  def compressed_response(hash)
    hash.map do
      {
        url: _1['html_url'],
        number: _1['number'],
        title: _1['title'],
        create_user: _1['user']['login'],
        is_pr: _1.key?('pull_request'),
        dates_not_updated: (Date.today - Date.parse(_1['updated_at'])).to_i
      }
    end
  end
end
