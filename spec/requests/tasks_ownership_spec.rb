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

  describe "POST /tasks" do
    it "creates a task for the current user" do
      params = { task: { title: "New Task", description: "New desc", completed: false } }
      post "/tasks", params: params, headers: auth_header(user)
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("New Task")
      expect(body["user_id"]).to eq(user.id)
    end
  end

  describe "PATCH /tasks/:id" do
    it "updates own task" do
      target = user_tasks.first
      patch "/tasks/#{target.id}", params: { task: { title: "Updated" } }, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Updated")
      expect(target.reload.title).to eq("Updated")
    end

    it "prevents updating another user's task" do
      patch "/tasks/#{other_task.id}", params: { task: { title: "Hacked" } }, headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes own task" do
      target = user_tasks.first
      delete "/tasks/#{target.id}", headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      expect(Task.exists?(target.id)).to be_falsey
    end

    it "prevents deleting another user's task" do
      delete "/tasks/#{other_task.id}", headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
      expect(Task.exists?(other_task.id)).to be_truthy
    end
  end

  describe "PATCH /tasks/:id/reorder" do
    it "reorders own task" do
      a = create(:task, user: user, position: 501)
      b = create(:task, user: user, position: 502)
      c = create(:task, user: user, position: 503)

      patch "/tasks/#{c.id}/reorder", params: { task: { position: a.position } }, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      c.reload
      expect(c.position).to be > a.position
      expect(c.position).to be < b.position

      patch "/tasks/#{b.id}/reorder", params: { task: { position: a.position } }, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      b.reload
      expect(b.position).to be > a.position
      expect(b.position).to be < c.position
    end

    it "prevents reordering another user's task" do
      patch "/tasks/#{other_task.id}/reorder", params: { task: { position: 1.5 } }, headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
    end
  end
end
