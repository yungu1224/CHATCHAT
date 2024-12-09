package chat;

import java.io.IOException;
import java.net.URLDecoder;
import java.util.ArrayList;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import user.UserDAO;

@WebServlet("/ChatBoxServlet")
public class ChatBoxServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        String userID = request.getParameter("userID");
        if (userID == null || userID.equals("")) {
            response.getWriter().write("");
        } else {
            try {
                HttpSession session = request.getSession();
                if (!URLDecoder.decode(userID, "UTF-8").equals((String) session.getAttribute("userID"))) {
                    response.getWriter().write("");
                    return;
                }
                userID = URLDecoder.decode(userID, "UTF-8");
                response.getWriter().write(getBox(userID));
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("");
            }
        }
    }

    public String getBox(String userID) {
        StringBuffer result = new StringBuffer("");
        result.append("{\"result\":[");
        ChatDAO chatDAO = new ChatDAO();
        ArrayList<ChatDTO> chatList = chatDAO.getBox(userID);
        if (chatList.size() == 0) return "";

        for (int i = chatList.size() - 1; i >= 0; i--) {
            String unread = "";
            String userProfile = "";

            if (userID.equals(chatList.get(i).getToID())) {
                unread = chatDAO.getUnreadChat(chatList.get(i).getFromID(), userID) + "";
                if (unread.equals("0")) unread = "";
            }

            // 프로필 이미지 가져오기
            if (userID.equals(chatList.get(i).getToID())) {
                userProfile = new UserDAO().getProfile(chatList.get(i).getFromID());
            } else {
                userProfile = new UserDAO().getProfile(chatList.get(i).getToID());
            }

            // 기본 프로필 이미지 설정
            if (userProfile == null || userProfile.isEmpty()) {
                userProfile = "http://localhost:8090/upload/icon.jpg";
            }

            result.append("[{\"value\": \"" + chatList.get(i).getFromID() + "\"},");
            result.append("{\"value\": \"" + chatList.get(i).getToID() + "\"},");
            result.append("{\"value\": \"" + chatList.get(i).getChatContent() + "\"},");
            result.append("{\"value\": \"" + chatList.get(i).getChatTime() + "\"},");
            result.append("{\"value\": \"" + unread + "\"},");
            result.append("{\"value\": \"" + userProfile + "\"}]");
            if (i != 0) result.append(",");
        }
        result.append("], \"last\":\"" + chatList.get(chatList.size() - 1).getChatID() + "\"}");
        return result.toString();
    }
}
