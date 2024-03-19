# name: discourse-set-user-ip
# about: An api route to set registration ip address of a user
# version: 1.0
# authors: NubeBuster
# url: https://github.com/NubeBuster/discourse-set-user-ip


enabled_site_setting :set_user_ip_enabled

after_initialize do
    load File.expand_path('../config/routes.rb', __FILE__)
  
    module ::SetUserIp
      class SetUserIpController < ::ApplicationController
        requires_plugin 'set-user-ip'

        before_action :ensure_admin
  
        def set_ip
          user_id = params[:id]
          new_ip = params[:ip]
          if user_id.blank? || new_ip.blank?
            render json: { error: "User ID and IP must be provided." }, status: :bad_request
            return
          end
    
          update(user_id, new_ip)
          render json: { success: true }
        end
  
        private

        def update(user_id, new_ip)
          # Protect against SQL injection by using parameterized queries
          DB.exec <<~SQL, user_id: user_id, new_ip: new_ip
            UPDATE users SET registration_ip_address = :new_ip WHERE id = :user_id;
          SQL
        end
    
  
        def ensure_admin
          raise Discourse::InvalidAccess.new unless current_user&.admin?
        end
      end
    end
  end
