package chat;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class ChatRoomRegistry {
    private static ChatRoomRegistry instance = new ChatRoomRegistry();
    private Map<String, ChatRoom> chatRooms = new HashMap<>();

    private ChatRoomRegistry() {}

    public static ChatRoomRegistry getInstance() {
        return instance;
    }

    public ChatRoom createRoom(String topic) {
        String roomID = UUID.randomUUID().toString();
        ChatRoom newRoom = new ChatRoom(roomID, topic);
        chatRooms.put(roomID, newRoom);
        return newRoom;
    }

    public ChatRoom getRoom(String roomID) {
        return chatRooms.get(roomID);
    }

    public Map<String, ChatRoom> getAllRooms() {
        return chatRooms;
    }
}
