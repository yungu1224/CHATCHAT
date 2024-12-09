package chat;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.*;

@ServerEndpoint("/UserChat/chat/{roomID}")
public class GroupChatWebSocket {
    private static Map<String, ChatRoom> chatRooms = new HashMap<>(); // 채팅방 목록 관리
    private static Map<Session, String> users = new HashMap<>();
    private static Map<Session, String> profileImages = new HashMap<>();
    private ChatDAO chatDAO = new ChatDAO();
    private String roomID;

    private static final String DEFAULT_PROFILE_IMAGE = "http://localhost:8090/upload/icon.jpg";

    @OnOpen
    public void onOpen(Session session, @PathParam("roomID") String roomID) {
        this.roomID = roomID;

        // 채팅방이 없으면 생성
        chatRooms.putIfAbsent(roomID, new ChatRoom(roomID, "Default Topic"));

        // 해당 채팅방에 세션 추가
        ChatRoom chatRoom = chatRooms.get(roomID);
        chatRoom.addUser(session);

        System.out.println("User connected to room: " + roomID);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        if (roomID == null || roomID.trim().isEmpty()) {
            System.out.println("roomID is null or empty. Message will not be saved.");
            return;
        }

        if (message == null || message.trim().isEmpty()) {
            System.out.println("Empty message received. Ignoring.");
            return;
        }

        String userID = users.get(session);
        String profileImage = profileImages.get(session);

        if (message.startsWith("USERID:")) {
            String[] parts = message.split(";");
            userID = parts[0].substring(7); // "USERID:" 제거
            profileImage = parts.length > 1 && !parts[1].trim().isEmpty()
                    ? parts[1]
                    : DEFAULT_PROFILE_IMAGE; // 기본값 설정

            users.put(session, userID);
            profileImages.put(session, profileImage);

            broadcastMessage(profileImage, userID + " 님이 채팅방에 연결되었습니다.");
        } else {
            if (userID != null) {
                profileImage = (profileImage == null || profileImage.isEmpty()) ? DEFAULT_PROFILE_IMAGE : profileImage;
                chatDAO.saveGroupChatMessage(roomID, userID, profileImage, message); // 메시지 저장
                broadcastMessage(profileImage, userID + ": " + message);
            }
        }
    }

    @OnClose
    public void onClose(Session session) {
        // 채팅방에서 세션 제거
        ChatRoom chatRoom = chatRooms.get(roomID);
        if (chatRoom != null) {
            chatRoom.removeUser(session);
            System.out.println("User disconnected from room: " + roomID);

            // 채팅방에 사용자가 없으면 채팅방 삭제 (선택 사항)
            if (chatRoom.getUsers().isEmpty()) {
                chatRooms.remove(roomID);
                System.out.println("Room " + roomID + " is now empty and has been removed.");
            }
        }

        String userID = users.remove(session);
        String profileImage = profileImages.remove(session);
        if (userID != null) {
            broadcastMessage(profileImage, userID + " 님이 채팅방을 나갔습니다.");
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        throwable.printStackTrace();
    }

    private void broadcastMessage(String profileImage, String message) {
        // 모든 사용자에게 메시지 전송
        ChatRoom chatRoom = chatRooms.get(roomID);
        if (chatRoom != null) {
            for (Session user : chatRoom.getUsers()) {
                if (user.isOpen()) {
                    try {
                        user.getBasicRemote().sendText(profileImage + ";" + message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    // 채팅방 삭제
    public static void deleteChatRoom(String roomID) {
        ChatRoom chatRoom = chatRooms.get(roomID);
        if (chatRoom != null) {
            // 채팅방에 연결된 모든 세션에 "EXIT" 메시지 전송
            for (Session session : chatRoom.getUsers()) {
                try {
                    session.getBasicRemote().sendText("EXIT"); // 강제 종료 메시지 전송
                    session.close(); // WebSocket 세션 종료
                } catch (Exception e) {
                    e.printStackTrace(); // 예외 처리
                }
            }
            // 채팅방 목록에서 제거
            chatRooms.remove(roomID);
            System.out.println("채팅방 " + roomID + "이 삭제되었습니다.");
        } else {
            System.out.println("채팅방 " + roomID + "을 찾을 수 없습니다.");
        }
    }

}
