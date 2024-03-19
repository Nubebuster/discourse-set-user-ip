# Discourse set user ip api route

An api route to set registration ip address of a user. This can be used if you register users externally using the built-in createUser route. In this situation the registration ip of the user is set to the server you are creating them from.

This plugin was created to setup a minecraft spigot plugin command for signing up to the forums.

# Route

POST /admin/set_user_ip#set_ip

id=Number&ip=String

# Example code for Java
