# config/routes.rb
Discourse::Application.routes.append do
  post "/admin/set_user_ip" => "set_user_ip/set_user_ip#set_ip"
end
