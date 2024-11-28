json.extract! team_member, :id, :name, :role, :project_id, :created_at, :updated_at
json.url team_member_url(team_member, format: :json)
