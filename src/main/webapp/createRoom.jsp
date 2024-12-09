<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="chat.ChatDAO, chat.ChatRoom" %>
<%
    // 세션에서 로그인한 사용자 ID 가져오기
    String userID = (String) session.getAttribute("userID");

    // 사용자 ID 확인
    if (userID == null) {
        // JavaScript alert로 메시지 출력 후 로그인 페이지로 이동
        out.println("<script>");
        out.println("alert('로그인이 필요합니다.');");
        out.println("location.href='index.jsp';");
        out.println("</script>");
        return;
    }

    String topic = request.getParameter("topic"); // 채팅방 제목을 폼에서 받아옴
    String roomID = java.util.UUID.randomUUID().toString(); // UUID를 사용해 고유한 roomID 생성

    if (topic != null && !topic.trim().isEmpty()) {
        ChatDAO chatDAO = new ChatDAO();
        int result = chatDAO.createGroupChatRoom(roomID, topic, userID); // userID 추가

        if (result > 0) {
            // 성공 메시지 출력 후 채팅방 목록으로 이동
            out.println("<script>");
            out.println("alert('채팅방이 생성되었습니다.');");
            out.println("location.href='chatRoomList.jsp';");
            out.println("</script>");
        } else {
            // 실패 메시지 출력
            out.println("<script>");
            out.println("alert('채팅방 생성에 실패했습니다. 다시 시도해주세요.');");
            out.println("history.back();"); // 이전 페이지로 이동
            out.println("</script>");
        }
    } else {
        // 제목 입력 요청 메시지 출력
        out.println("<script>");
        out.println("alert('채팅방 제목을 입력해 주세요.');");
        out.println("history.back();"); // 이전 페이지로 이동
        out.println("</script>");
    }
%>
