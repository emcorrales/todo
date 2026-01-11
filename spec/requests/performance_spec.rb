require 'rails_helper'
require 'benchmark'

RSpec.describe "Performance", type: :request do
  # This is an expensive test. It's skipped by default.
  # To run: `PERF=1 bundle exec rspec spec/requests/performance_spec.rb`
  before do
    skip "Performance tests disabled; set PERF=1 to run" unless ENV['PERF'] == '1'
  end

  it "returns 1_000_000 tasks in under 5 seconds" do
    user = create(:user)

    # Bulk-insert 1_000_000 tasks for the user using insert_all in batches.
    total = 1_000_000
    batch_size = 50_000
    now = Time.now

    (0...(total / batch_size)).each do |batch|
      offset = batch * batch_size
      records = Array.new(batch_size) do |i|
        idx = offset + i + 1
        { title: "Task "+idx.to_s, position: idx, user_id: user.id, created_at: now, updated_at: now }
      end
      Task.insert_all(records)
    end

    remainder = total % batch_size
    if remainder.positive?
      records = Array.new(remainder) do |i|
        idx = (total - remainder) + i + 1
        { title: "Task "+idx.to_s, position: idx, user_id: user.id, created_at: now, updated_at: now }
      end
      Task.insert_all(records)
    end

    token = JwtService.encode(user_id: user.id)
    headers = { "Authorization" => "Bearer "+token, "ACCEPT" => "application/json" }

    elapsed = Benchmark.realtime do
      get "/tasks", headers: headers
      expect(response).to have_http_status(:ok)
    end

    expect(elapsed).to be < 5.0
  end
end
