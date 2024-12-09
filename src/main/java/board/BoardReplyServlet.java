package board;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/BoardReplyServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class BoardReplyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 고정된 저장 경로 사용
        String savePath = "C:/upload";
        File uploadDir = new File(savePath);

        // 디렉토리 생성 확인 및 로깅
        if (!uploadDir.exists()) {
            if (uploadDir.mkdirs()) {
                System.out.println("Upload directory created: " + savePath);
            } else {
                System.out.println("Failed to create upload directory: " + savePath);
                response.getWriter().write("업로드 디렉토리 생성에 실패했습니다.");
                return;
            }
        }

        // HttpSession 가져오기
        HttpSession session = request.getSession();
        String userID = request.getParameter("userID");

        // 세션 사용자 ID와 요청 사용자 ID가 같은지 확인
        if (!userID.equals((String) session.getAttribute("userID"))) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "접근할 수 없습니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        // 게시글 ID 확인
        String boardID = request.getParameter("boardID");
        if (boardID == null || boardID.equals("")) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "게시글 ID가 없습니다.");
            response.sendRedirect("index.jsp");
            return;
        }

        // 제목과 내용 확인
        String boardTitle = request.getParameter("boardTitle");
        String boardContent = request.getParameter("boardContent");
        if (boardTitle == null || boardTitle.trim().equals("") || boardContent == null || boardContent.trim().equals("")) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "내용을 모두 입력해 주세요.");
            response.sendRedirect("index.jsp");
            return;
        }

        // 파일 처리
        String boardFile = "";
        String boardRealFile = "";
        Part filePart = request.getPart("boardProfile");

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = extractFileName(filePart); // 파일 이름 추출
            if (fileName != null && !fileName.isEmpty()) {
                boardFile = fileName; // 클라이언트가 보낸 파일 이름
                boardRealFile = fileName; // 서버에 저장될 파일 이름
                filePart.write(savePath + "/" + boardRealFile); // 파일 저장
                System.out.println("File uploaded successfully: " + savePath + "/" + boardRealFile);
            }
        }

        // 답글 처리 로직
        BoardDAO boardDAO = new BoardDAO();
        BoardDTO parent = boardDAO.getBoard(boardID); // 부모 게시글 정보 가져오기
        boardDAO.replyUpdate(parent); // 부모 글에 대한 업데이트 (예: 답변 상태 변경)
        boardDAO.reply(userID, boardTitle, boardContent, boardFile, boardRealFile, parent); // 답글 작성

        session.setAttribute("messageType", "성공메세지");
        session.setAttribute("messageContent", "성공적으로 답변이 작성되었습니다.");
        response.sendRedirect("boardView.jsp");
    }

    // 파일 이름 추출 유틸리티 메서드
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}
