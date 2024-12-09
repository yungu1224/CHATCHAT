<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO, chat.ChatDAO, chat.ChatDTO"%>
<%@ page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html>
<head>
<%
        // 로그인 확인
        String userID = (String) session.getAttribute("userID");
        if (userID == null) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "현재 로그인이 되어 있지 않습니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        // 기본 프로필 이미지 경로
        String defaultProfileImage = "http://localhost:8090/upload/icon.jpg";

        // 현재 사용자 및 채팅방 정보
        UserDAO userDAO = new UserDAO();
        String fromProfile = userDAO.getProfile(userID);
        fromProfile = (fromProfile == null || fromProfile.isEmpty()) ? defaultProfileImage : fromProfile;

        String roomID = request.getParameter("roomID");
        if (roomID == null || roomID.isEmpty()) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "채팅방 정보가 없습니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        ChatDAO chatDAO = new ChatDAO();
        String roomTopic = chatDAO.getRoomTopic(roomID); // 채팅방 주제 가져오기
        ArrayList<ChatDTO> chatMessages = chatDAO.getGroupChatMessages(roomID); // 채팅방 메시지 가져오기
    %>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>CHAT CHAT</title>
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/bootstrap.js"></script>
<script type="text/javascript">
    var socket;
    var userID = "<%= userID %>";
    var userProfile = "<%= fromProfile %>"; // 현재 사용자의 프로필 이미지
    var roomID = "<%= roomID %>";
    var defaultProfileImage = "<%= defaultProfileImage %>"; // 기본 프로필 이미지

    function connectWebSocket() {
        var socketURL = "ws://localhost:8090/UserChat/chat/" + roomID;
        console.log("WebSocket URL:", socketURL);
        socket = new WebSocket(socketURL);

        socket.onopen = function () {
            console.log("WebSocket 연결 성공");
            socket.send("USERID:" + userID + ";" + userProfile);
        };

        socket.onmessage = function (event) {
            var message = event.data;
            console.log("Received WebSocket message:", message);

            // 서버로부터 "EXIT" 메시지를 받으면 채팅방 목록으로 리디렉션
            if (message === "EXIT") {
                alert("채팅방이 삭제되었습니다.");
                window.location.href = "chatRoomList.jsp"; // 채팅방 목록으로 이동
            } else {
                addChat(message);
            }
        };

        socket.onclose = function () {
            console.log("WebSocket 연결 종료");
        };

        socket.onerror = function (error) {
            console.error("WebSocket 오류 발생:", error);
        };
    }


    function addChat(message) {
        var chatTime = new Date().toLocaleTimeString();
        var splitMessage = message.split(";");
        var profileImage = splitMessage[0] || defaultProfileImage; // 프로필 이미지가 없으면 기본값 사용
        var messageContent = splitMessage[1] || "";

        var splitContent = messageContent.split(": ");
        var sender = splitContent[0] ? splitContent[0] : "알 수 없음";
        var chatContent = splitContent[1] ? splitContent[1] : "";

        if (sender === userID) {
            sender = '나';
        }

        $('#chatList').append('<div class="row">' +
            '<div class="col-lg-12">' +
            '<div class="media">' +
            '<a class="pull-left" href="#"><img class="media-object img-circle" style="width: 30px; height: 30px;" src="' + profileImage + '" alt="프로필 이미지"></a>' +
            '<div class="media-body">' +
            '<h4 class="media-heading">' + sender +
            '<span class="small pull-right">' + chatTime + '</span>' +
            '</h4>' +
            '<p>' + chatContent + '</p>' +
            '</div>' +
            '</div>' +
            '</div>' +
            '</div><hr>');

        $('#chatList').scrollTop($('#chatList')[0].scrollHeight);
    }

    $(document).ready(function() {
        connectWebSocket();

        $('#sendBtn').click(function() {
            submitFunction();
        });

        $('#chatContent').keypress(function(e) {
            if (e.which == 13 && !e.shiftKey) {
                submitFunction();
                e.preventDefault();
            }
        });
    });

    function submitFunction() {
        var chatContent = $('#chatContent').val();
        if (socket.readyState === WebSocket.OPEN && chatContent.trim() !== "") {
            socket.send(chatContent);
            $('#chatContent').val('');
        } else {
            console.error("WebSocket 연결이 열려 있지 않거나 빈 메시지입니다.");
        }
    }
    </script>
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

	<div class="container bootstrap snippet">
		<div class="row">
			<div class="col-xs-12">
				<div class="portlet portlet-default">
					<div class="portlet-heading">
						<div class="portlet-title">
							<h4>
								<i class="fa fa-circle text-green"></i>
								<%= roomTopic %></h4>
						</div>
						<div class="clearfix"></div>
					</div>
					<div id="chat" class="panel-collapse collapse in">
						<div id="chatList" class="portlet-body chat-widget"
							style="overflow-y: auto; width: auto; height: 600px;">
							<% for (ChatDTO message : chatMessages) {
								String profileImage = (message.getProfileImage() != null && !message.getProfileImage().isEmpty())
									    ? message.getProfileImage()
									    : "http://localhost:8090/upload/icon.jpg";
                            %>
							<div class="row">
								<div class="col-lg-12">
									<div class="media">
										<a class="pull-left" href="#"> <img
											class="media-object img-circle"
											style="width: 30px; height: 30px;"
											src="<%= profileImage != null ? profileImage : "http://localhost:8090/upload/icon.jpg" %>"
											onerror="this.src='/images/icon.jpg';"
											alt="프로필 이미지">
										</a>
										<div class="media-body">
											<h4 class="media-heading"><%= message.getFromID() %>
												<span class="small pull-right"><%= message.getChatTime() %></span>
											</h4>
											<p><%= message.getChatContent() %></p>
										</div>
									</div>
								</div>
							</div>
							<hr>
							<% } %>
						</div>
						<div class="portlet-footer">
							<div class="row" style="height: 90px;">
								<div class="form-group col-xs-10">
									<textarea style="height: 80px;" id="chatContent"
										class="form-control" placeholder="메시지를 입력하세요" maxlength="100"></textarea>
								</div>
								<div class="form-group col-xs-2">
									<button type="button" id="sendBtn"
										class="btn btn-default pull-right">전송</button>
									<div class="clearfix"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
