# Discourse plugin - set user ip api route

An api route to set registration ip address of a user. This can be used if you register users externally using the built-in createUser route. In this situation the registration ip of the user is set to the server you are creating them from.

This plugin was created to setup a minecraft spigot plugin command for signing up to the forums.

# Route

POST /admin/set_user_ip#set_ip

id=Number&ip=String

# Example curl command

```
curl -X POST "http://127.0.0.1:3000/admin/set_user_ip#set_ip" \
-H "Content-Type: multipart/form-data;" \
-H "Api-Key: <key>" \
-H "Api-Username: <username>" \
-F "id=1" \
-F "ip=127.0.0.1"
```

# Example code for Java

```java
public CreateUserResponse createUser(String username, String email, String password, String ip) throws IOException {
    Map < String, Object > userData = new HashMap < > ();
    userData.put("name", username);
    userData.put("username", username);
    userData.put("email", email);
    userData.put("password", password);
    userData.put("active", "false");
    userData.put("approved", "true");
    userData.put("user_fields[1]", "true");
    CreateUserResponse res = post("/users.json", userData, CreateUserResponse.class);
    if (res != null && res.isSuccess()) {
        try {
            setIp(res.getUserId(), ip);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            //TODO handle this. Plugin is not installed or not enabled
        } catch (Exception e) {
            e.printStackTrace();
            //TODO handle this.
        }
    }
    return res;
}

private void setIp(int forumId, String ip) throws IOException {
    Map < String, Object > data = new HashMap < > ();
    data.put("id", forumId);
    data.put("ip", ip);
    post("/admin/set_user_ip#set_ip", data, null);
}

private < T > T post(String route, Map < String, Object > data, Class < T > responseClass) throws IOException {
    HttpURLConnection connection = getConnection(route, "POST");
    String boundary = Long.toHexString(System.currentTimeMillis()); // Just generate some unique random value.
    connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

    if (data != null) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(bos, StandardCharsets.UTF_8));

        for (Map.Entry < String, Object > entry: data.entrySet()) {
            writer.append("--").append(boundary).append("\r\n");
            writer.append("Content-Disposition: form-data; name=\"").append(entry.getKey()).append("\"");

            if (entry.getValue() instanceof byte[]) {
                writer.append("; filename=\"filename\"\r\nContent-Type: application/octet-stream\r\n\r\n");
                writer.flush();
                bos.write((byte[]) entry.getValue());
                writer.append("\r\n");
            } else {
                writer.append("\r\n\r\n").append(entry.getValue().toString()).append("\r\n");
            }
        }

        writer.append("--").append(boundary).append("--\r\n");
        writer.flush();

        try (OutputStream outputStream = connection.getOutputStream()) {
            bos.writeTo(outputStream);
        }
    }

    String response = response(connection);
    if (responseClass != null) {
        Gson gson = new Gson();
        return gson.fromJson(response, responseClass);
    }
    return null;
}

public class CreateUserResponse {

    private boolean success;
    private String message;

    private Map< String, String[] > errors;
    @SerializedName("is_developer")
    private boolean isDeveloper;

    @SerializedName("user_id")
    private int userId;

    public CreateUserResponse() {
        //empty constructor for GSON
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        String msg = message;
        //Remove html and add line seperators
        msg = msg.replace("</p>", "\n");
        msg = msg.replace(". ", ".\n");
        msg = msg.replaceAll("<[^>]+>", "");
        msg = msg.trim();
        return msg;
    }

    public Map< String, String[] > getErrors() {
        return errors;
    }

    public boolean isDeveloper() {
        return isDeveloper;
    }

    public int getUserId() {
        return userId;
    }
}


```
