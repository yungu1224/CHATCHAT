package user;

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

@WebServlet("/UserProfileServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class UserProfileServlet extends HttpServlet {
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

        // 파일 업로드 처리
        Part filePart = request.getPart("userProfile");
        String fileName = extractFileName(filePart);

        // 기존 파일 삭제 로직
        String prev = new UserDAO().getUser(userID).getUserProfile();
        File prevFile = new File(savePath + "/" + prev);
        if (prevFile.exists() && prevFile.isFile()) {  // 파일이 존재하고 파일일 때만 삭제
            System.out.println("Previous file exists, deleting: " + prevFile.getAbsolutePath());
            if (prevFile.delete()) {
                System.out.println("Previous file deleted: " + prevFile.getAbsolutePath());
            } else {
                System.out.println("Failed to delete previous file: " + prevFile.getAbsolutePath());
            }
        } else {
            System.out.println("No previous file to delete.");
        }

        // 새 파일 저장 및 처리 로직
        if (fileName != null && !fileName.isEmpty()) {
            String fileExt = fileName.substring(fileName.lastIndexOf(".") + 1);
            if (fileExt.equalsIgnoreCase("jpg") || fileExt.equalsIgnoreCase("png") || fileExt.equalsIgnoreCase("gif")) {
                // 파일 저장
                filePart.write(savePath + "/" + fileName);
                System.out.println("File uploaded successfully: " + savePath + "/" + fileName);
                new UserDAO().profile(userID, fileName);
                session.setAttribute("messageType", "성공메세지");
                session.setAttribute("messageContent", "성공적으로 변경되었습니다.");
            } else {
                System.out.println("Invalid file type: " + fileExt);
                session.setAttribute("messageType", "오류메세지");
                session.setAttribute("messageContent", "이미지 파일만 업로드 가능합니다.");
            }
        } else {
            System.out.println("No file uploaded.");
            session.setAttribute("messageType", "오류메세지");
            session.setAttribute("messageContent", "파일 업로드가 실패했습니다.");
        }
        response.sendRedirect("index.jsp");
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

