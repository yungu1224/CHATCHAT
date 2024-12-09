<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <%
        String userID = null;
        if(session.getAttribute("userID") != null){
            userID = (String) session.getAttribute("userID");
        }
    %>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="css/custom.css">
    <title>CHAT CHAT</title>
    <style>
        /* 글씨체를 좀 더 부드러운 스타일로 변경 */
        body {
            font-family: Arial, sans-serif;
        }

        .banner {
            width: 90%;
            max-width: 800px;
            margin: 60px auto;
            padding: 20px;
            color: black;
            font-size: 22px;
            font-weight: bold;
            text-align: center;
            border: 3px solid #007bff;
            box-sizing: border-box;
        }

        .shortcut-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            justify-content: center;
            max-width: 500px;
            margin: 40px auto; /* 상단과의 간격을 넓히기 위해 margin-top 값을 증가 */
        }

        .shortcut {
            width: 200px;
            height: 150px;
            background-color: #f0f0f0;
            border: 2px solid #007bff;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 18px;
            font-weight: bold;
            color: #007bff;
            text-align: center;
            cursor: pointer;
            transition: background-color 0.3s, color 0.3s;
        }
        .shortcut:hover {
            background-color: #007bff;
            color: white;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
    <script src="js/bootstrap.js"></script>
    <script type="text/javascript">
        function getUnread() {
            $.ajax({
                type: "POST",
                url: "./chatUnread",
                data: {
                    userID: encodeURIComponent('<%=userID%>'),
                },
                success: function(result) {
                    console.log(result);
                    if (result >= 1) {
                        showUnread(result);
                    } else {
                        showUnread('');
                    }
                }
            });
        }
        function getInfiniteUnread() {
            setInterval(function() {
                getUnread();
            }, 1000);
        }
        function showUnread(result) {
            $('#unread').html(result);
        }
    </script>
</head>
<body>
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
                <li class="active"><a href="index.jsp">메인</a>
                <li><a href="find.jsp">친구찾기</a></li>
                <li><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li>
                <li><a href="boardView.jsp">자유게시판</a></li>
                <li><a href="chatRoomList.jsp">단체채팅</a></li>
            </ul>
            <%
                if(userID==null){
            %>
            <ul class="nav navbar-nav navbar-right">
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle"
                        data-toggle="dropdown" role="button" aria-haspopup="true"
                        aria-expanded="false">접속하기<span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a href="login.jsp">로그인</a></li>
                        <li><a href="join.jsp">회원가입</a></li>
                    </ul>
                </li>
            </ul>
            <% 
                } else {
            %>
            <ul class="nav navbar-nav navbar-right">
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle"
                        data-toggle="dropdown" role="button" aria-haspopup="true"
                        aria-expanded="false">회원관리<span class="caret"></span>
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

    <!-- 사진 느낌의 배너 -->
    <div class="banner">
        채팅과 자유게시판으로 주변 사람들과 자유롭게 소통하세요<br><br>
        매너있는 웹사이트 이용 부탁드립니다<br><br>
        오늘도 즐거운 하루되세요
    </div>

    <!-- 2x2 기능 바로가기 버튼 배치 -->
    <div class="shortcut-container">
        <div class="shortcut" onclick="location.href='find.jsp'">친구찾기<br>바로가기</div>
        <div class="shortcut" onclick="location.href='box.jsp'">메시지함<br>바로가기</div>
        <div class="shortcut" onclick="location.href='boardView.jsp'">자유게시판<br>바로가기</div>
        <div class="shortcut" onclick="location.href='newchat.jsp'">단체채팅<br>바로가기</div>
    </div>

    <%
        String messageContent = null;
        if (session.getAttribute("messageContent") != null){
            messageContent = (String) session.getAttribute("messageContent");
        }
        String messageType = null;
        if (session.getAttribute("messageType") != null){
            messageType = (String) session.getAttribute("messageType");
        }
        if (messageContent != null){
    %>
    <div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="vertical-alignment-helper">
            <div class="modal-dialog vertical-align-center">
                <div class="modal-content <% if(messageType.equals("오류메세지")) out.println("panel-warning"); else out.println("panel-success"); %>">
                    <div class="modal-header panel-heading">
                        <button type="button" class="close" data-dismiss="modal">
                            <span aria-hidden="true">&times</span>
                            <span class="sr-only">Close</span>
                        </button>
                        <h4 class="modal-title"><%= messageType %></h4>
                    </div>
                    <div class="modal-body">
                        <%= messageContent %>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>
                    </div>    
                </div>
            </div>
        </div>    
    </div>
    <script>
        $('#messageModal').modal("show");
    </script>        
    <%
        session.removeAttribute("messageContent");
        session.removeAttribute("messageType");
        }
    %>
    <%
        if(userID != null){
    %>
    <script type="text/javascript">
        $(document).ready(function(){
            getInfiniteUnread();
        });
    </script>
    <%
        }
    %>
</body>
</html>
