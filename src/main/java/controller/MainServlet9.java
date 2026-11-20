package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = { "/customer", "/manager" })
public class MainServlet9 extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String view = "/manager".equals(request.getServletPath())
                ? "/manager/ManagerMainUI9.jsp" : "/customer/CustomerMainUI9.jsp";
        request.getRequestDispatcher("/WEB-INF/views" + view).forward(request, response);
    }
}
