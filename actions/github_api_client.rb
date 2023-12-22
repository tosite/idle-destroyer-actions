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
    targets = []
    puts "REQUEST URL: #{@base_url}/issues"
    loop do
      response = conn.get('issues', { state: 'open', per_page: 100, page: page }, @headers)
      rows = JSON.parse(response.body)
      break if response.status != 200 || rows.empty?
      targets << rows.select { |row|
        puts "---- #{row['title']} / #{row['url']} ----"
        puts "  term: #{row['updated_at']} < #{limit}"
        puts "  labels: #{row['labels'].map { _1['name'] }.join(', ')}"
        within_term = limit < row['updated_at']
        has_exclusion_label = row['labels'].any? { |label|
          @ignore_labels.include?(label['name'])
        }
        is_target = !within_term && !has_exclusion_label
        puts "  #{is_target ? 'Target' : 'Skip  '}(within_term: #{within_term}, has_exclusion_label: #{has_exclusion_label})"
        is_target
      }
      page += 1
    end
    compressed_response(targets.flatten)
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
        labels: _1['labels'].map { |l| l['name'] },
        dates_not_updated: (Date.today - Date.parse(_1['updated_at'])).to_i
      }
    end
  end
end
