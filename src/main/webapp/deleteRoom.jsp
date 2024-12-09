<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="chat.ChatDAO, chat.GroupChatWebSocket" %>
<%
    String roomID = request.getParameter("roomID");
    ChatDAO chatDAO = new ChatDAO();

    // 데이터베이스에서 채팅방 삭제
    int result = chatDAO.deleteChatRoom(roomID);

    if (result > 0) {
        // WebSocket 세션 종료 및 채팅방 제거
        GroupChatWebSocket.deleteChatRoom(roomID);
        response.getWriter().write("채팅방이 성공적으로 삭제되었습니다.");
    } else {
        response.getWriter().write("채팅방 삭제에 실패했습니다.");
    }
%>
