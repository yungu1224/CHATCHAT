package chat;

import jakarta.websocket.Session;
import java.util.HashSet;
import java.util.Set;

public class ChatRoom {
    private String roomID;
    private String topic;
    private Set<Session> users;

    public ChatRoom(String roomID, String topic) {
        this.roomID = roomID;
        this.topic = topic;
        this.users = new HashSet<>();
    }

    public String getRoomID() {
        return roomID;
    }

    public String getTopic() {
        return topic;
    }

    public void addUser(Session session) {
        users.add(session);
    }

    public void removeUser(Session session) {
        users.remove(session);
    }

    public Set<Session> getUsers() {
        return users;
    }
}
