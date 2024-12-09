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

@WebServlet("/BoardUpdateServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class BoardUpdateServlet extends HttpServlet {
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

        // 게시글 가져오기
        BoardDAO boardDAO = new BoardDAO();
        BoardDTO board = boardDAO.getBoard(boardID);
        if (!userID.equals(board.getUserID())) {
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "해당 게시글에 접근할 수 없습니다.");
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
        Part filePart = request.getPart("boardFile");

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = extractFileName(filePart); // 파일 이름 추출
            if (fileName != null && !fileName.isEmpty()) {
                boardFile = fileName; // 클라이언트가 보낸 파일 이름
                boardRealFile = fileName; // 서버에 저장될 파일 이름

                // 기존 파일 삭제
                String prev = boardDAO.getRealFile(boardID);
                File prevFile = new File(savePath + "/" + prev);
                if (prevFile.exists() && prevFile.isFile()) { // 파일이 존재하고 파일일 때만 삭제
                    System.out.println("Previous file exists, deleting: " + prevFile.getAbsolutePath());
                    if (prevFile.delete()) {
                        System.out.println("Previous file deleted: " + prevFile.getAbsolutePath());
                    } else {
                        System.out.println("Failed to delete previous file: " + prevFile.getAbsolutePath());
                    }
                }

                // 새 파일 저장
                filePart.write(savePath + "/" + boardRealFile);
                System.out.println("File uploaded successfully: " + savePath + "/" + boardRealFile);
            }
        } else {
            // 파일이 업로드되지 않은 경우 기존 파일 사용
            boardFile = boardDAO.getFile(boardID);
            boardRealFile = boardDAO.getRealFile(boardID);
        }

        // 게시글 수정 처리
        boardDAO.update(boardID, boardTitle, boardContent, boardFile, boardRealFile);
        session.setAttribute("messageType", "성공메세지");
        session.setAttribute("messageContent", "게시글이 성공적으로 수정되었습니다.");
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
