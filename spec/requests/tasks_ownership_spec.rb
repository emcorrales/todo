require 'rails_helper'

RSpec.describe "Task ownership", type: :request do
  let!(:user) { create(:user) }
  let!(:other) { create(:user) }

  let!(:user_tasks) { create_list(:task, 2, user: user) }
  let!(:other_task) { create(:task, user: other) }

  def auth_header(u)
    token = JwtService.encode(user_id: u.id)
    { "Authorization" => "Bearer "+token, "ACCEPT" => "application/json" }
  end

  describe "GET /tasks" do
    it "returns only the current user's tasks" do
      get "/tasks", headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(user_tasks.length)
      ids = body.map { |t| t["id"] }
      expect(ids).to match_array(user_tasks.map(&:id))
    end
  end

  describe "GET /tasks/:id" do
    it "allows access to own task" do
      get "/tasks/#{user_tasks.first.id}", headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(user_tasks.first.id)
    end

    it "prevents access to another user's task" do
      get "/tasks/#{other_task.id}", headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
    end
  end
end
