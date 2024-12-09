<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "board.BoardDAO" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.text.*" %>
<%@ page import = "java.lang.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>CHAT CHAT</title>
</head>
<body>
    <%
        request.setCharacterEncoding("UTF-8");
        String boardID = request.getParameter("boardID");

        if (boardID == null || boardID.trim().equals("")) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "잘못된 접근입니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        String root = request.getSession().getServletContext().getRealPath("/");
        String savePath = "C:/upload";
        String fileName = "";
        String realFile = "";
        BoardDAO boardDAO = new BoardDAO();
        fileName = boardDAO.getFile(boardID);
        realFile = boardDAO.getRealFile(boardID);

        if (fileName == null || fileName.trim().equals("") || realFile == null || realFile.trim().equals("")) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "파일이 존재하지 않습니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        File file = new File(savePath, realFile);
        if (!file.exists()) {
            out.println("<script>alert('파일을 찾을 수 없습니다.');history.back();</script>");
            return;
        }

        String client = request.getHeader("User-Agent");

        try (InputStream in = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            response.reset();
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Description", "JSP Generated Data");

            if (client.indexOf("MSIE") != -1 || client.indexOf("Trident") != -1) {
                // IE 브라우저 처리
                response.setHeader("Content-Disposition", "attachment; filename=" + new String(fileName.getBytes("KSC5601"), "ISO8859_1"));
            } else {
                // 다른 브라우저 처리
                fileName = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            }

            response.setHeader("Content-Length", String.valueOf(file.length()));

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }

        } catch (IOException e) {
            e.printStackTrace();
            out.println("<script>alert('파일 다운로드 중 오류가 발생했습니다.');history.back();</script>");
        }
    %>
</body>
</html>
