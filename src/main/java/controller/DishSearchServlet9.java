package controller;

import dao.DishDAO9;
import model.Dish9;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;

@WebServlet("/dishes")
public class DishSearchServlet9 extends HttpServlet {
    private DishDAO9 dishDAO;

    @Override
    public void init() {
        dishDAO = new DishDAO9();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        if (request.getParameter("id") != null) {
            viewDishDetail(request, response);
        } else if (request.getParameter("q") != null) {
            searchDish(request, response);
        } else {
            showSearchPage(request, response);
        }
    }

    private void showSearchPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("keyword", "");
        request.setAttribute("listDishes", new Dish9[0]);
        show(request, response, "/WEB-INF/views/customer/DishSearchUI9.jsp");
    }

    private void searchDish(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        keyword = keyword == null ? "" : keyword.strip();
        request.setAttribute("keyword", keyword);
        if (keyword.isEmpty()) {
            request.setAttribute("listDishes", new Dish9[0]);
            request.setAttribute("notification", "Vui lòng nhập tên món ăn.");
        } else if (keyword.length() > 150) {
            response.setStatus(400);
            request.setAttribute("notification", "Tên món ăn không được vượt quá 150 ký tự.");
            request.setAttribute("listDishes", new Dish9[0]);
        } else {
            try {
                Dish9[] listDishes = Arrays.stream(dishDAO.getDishByName(keyword))
                        .filter(dish -> !dish.isDiscontinued()).toArray(Dish9[]::new);
                request.setAttribute("listDishes", listDishes);
                if (listDishes.length == 0) {
                    request.setAttribute("notification", "Không tìm thấy món ăn phù hợp.");
                }
            } catch (SQLException ex) {
                getServletContext().log("Dish search failed", ex);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                request.setAttribute("listDishes", new Dish9[0]);
                request.setAttribute("notification", "Không thể truy vấn dữ liệu món ăn.");
            }
        }
        if (request.getAttribute("unavailableDishNotification") != null
                && response.getStatus() != HttpServletResponse.SC_INTERNAL_SERVER_ERROR) {
            request.setAttribute("notification", request.getAttribute("unavailableDishNotification"));
        }
        show(request, response, "/WEB-INF/views/customer/DishSearchUI9.jsp");
    }

    private void viewDishDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        try {
            int dishId = Integer.parseInt(request.getParameter("id"));
            if (dishId <= 0)
                throw new NumberFormatException("Invalid dish ID");
            Dish9 dish = dishDAO.getDishDetail(dishId);
            if (dish == null || dish.isDiscontinued()) {
                response.setStatus(
                        dish == null ? HttpServletResponse.SC_NOT_FOUND : HttpServletResponse.SC_GONE);
                request.setAttribute("unavailableDishNotification",
                        "Món ăn này hiện đã ngừng phục vụ hoặc không còn tồn tại trên hệ thống.");
                searchDish(request, response);
                return;
            }
            request.setAttribute("dish", dish);
        } catch (NumberFormatException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("notification", "Mã món ăn không hợp lệ.");
        } catch (SQLException ex) {
            getServletContext().log("Dish detail lookup failed", ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("notification", "Không thể lấy thông tin món ăn.");
        }
        show(request, response, "/WEB-INF/views/customer/DishDetailUI9.jsp");
    }

    private void show(HttpServletRequest request, HttpServletResponse response, String file)
            throws ServletException, IOException {
        request.getRequestDispatcher(file).forward(request, response);
    }

}
