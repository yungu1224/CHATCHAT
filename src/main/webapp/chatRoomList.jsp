<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, chat.ChatRoomRegistry, chat.ChatRoom, user.UserDAO, chat.ChatDAO" %>
<!DOCTYPE html>
<html>
<head>
    <%
        String userID = (String) session.getAttribute("userID");
        if (userID == null) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "현재 로그인이 되어 있지 않습니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        UserDAO userDAO = new UserDAO();
        String fromProfile = userDAO.getProfile(userID);
    %>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="css/custom.css">
    <title>CHAT CHAT</title>
    <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
    <script src="js/bootstrap.js"></script>
</head>
<body>

    <!-- 네비게이션 바 -->
    <nav class="navbar navbar-default">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed"
                data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
                aria-expanded="false">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="index.jsp">CHAT CHAT</a>
        </div>
        <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
            <ul class="nav navbar-nav">
                <li><a href="index.jsp">메인</a></li>
                <li><a href="find.jsp">친구찾기</a></li>
                <li><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li>
                <li><a href="boardView.jsp">자유게시판</a></li>
                <li class="active"><a href="chatRoomList.jsp">단체채팅</a></li>
            </ul>
            <%
                if(userID != null) {  // 로그인되어 있는 경우에만 회원관리 표시
            %>
            <ul class="nav navbar-nav navbar-right">
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                        회원관리<span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a href="update.jsp">회원정보수정</a></li>
                        <li><a href="profileUpdate.jsp">프로필 수정</a></li>
                        <li><a href="logoutAction.jsp">로그아웃</a></li>
                    </ul>
                </li>
            </ul>
            <%
                }
            %>
        </div>
    </nav>

    <!-- 채팅방 생성 폼과 목록 -->
    <div class="container">
        <h1>채팅방 목록</h1>
        
        <!-- 채팅방 생성 폼을 상단으로 이동 -->
        <form action="createRoom.jsp" method="post" class="form-inline" style="margin-bottom: 20px;">
            <div class="form-group">
                <input type="text" name="topic" placeholder="채팅방 제목" class="form-control">
            </div>
            <button type="submit" class="btn btn-primary">채팅방 생성</button>
        </form>

        <!-- 채팅방 목록 -->
        <ul class="list-group">
    <%
    	ChatDAO chatDAO = new ChatDAO();
        List<ChatRoom> rooms = chatDAO.getAllGroupChatRooms();
        for (ChatRoom room : rooms) {
            String roomCreatorID = chatDAO.getRoomCreatorID(room.getRoomID());
    %>
    <li class="list-group-item">
        <a href="chatRoom.jsp?roomID=<%= room.getRoomID() %>"><%= room.getTopic() %></a>
        <% if (roomCreatorID.equals(userID)) { %>
            <button class="btn btn-danger btn-sm" onclick="deleteChatRoom('<%= room.getRoomID() %>')">삭제</button>
        <% } %>
    </li>
    <% } %>
</ul>

<script>
    function deleteChatRoom(roomID) {
        if (confirm('채팅방을 삭제하시겠습니까?')) {
            $.ajax({
                url: 'deleteRoom.jsp',
                type: 'POST',
                data: { roomID: roomID },
                success: function (response) {
                    alert(response);
                    location.reload(); // 페이지 새로고침
                },
                error: function () {
                    alert('채팅방 삭제에 실패했습니다.');
                }
            });
        }
    }
</script>

    </div>

</body>
</html>
