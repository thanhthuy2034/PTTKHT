<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!doctype html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>
            Chọn điều kiện thống kê
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/restman.css">
    </head>
    <body>
        <main class="shell narrow">
            <h1>CHỌN ĐIỀU KIỆN THỐNG KÊ</h1>
            <c:if test="${not empty notification}">
                <div class="notification">
                    <c:out value="${notification}"/>
                </div>
            </c:if>
            <form class="condition-form" method="post" action="${pageContext.request.contextPath}/supplier-statistics">
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                <div class="form-row">
                    <label for="statisticsType">Loại thống kê:</label>
                    <select name="statisticsType" id="statisticsType">
                        <option value="dish" disabled>Thống kê món ăn (Chưa triển khai)</option>
                        <option value="material" disabled>Thống kê nguyên liệu (Chưa triển khai)</option>
                        <option value="customer" disabled>Thống kê khách hàng (Chưa triển khai)</option>
                        <option value="supplier" selected>Nhà cung cấp theo lượng nhập</option>
                    </select>
                </div>
                <div class="form-row">
                    <label for="startDate">Ngày bắt đầu:</label>
                    <input
                        type="date"
                        lang="vi-VN"
                        min="1000-01-01"
                        id="startDate"
                        name="startDate"
                        value="<c:out value='${startDate}'/>"
                        max="${today}"
                        required>
                </div>
                <div class="form-row">
                    <label for="endDate">Ngày kết thúc:</label>
                    <input
                        type="date"
                        lang="vi-VN"
                        min="1000-01-01"
                        id="endDate"
                        name="endDate"
                        value="<c:out value='${endDate}'/>"
                        max="${today}"
                        required>
                </div>
                <div class="toolbar spaced">
                    <a class="button" href="${pageContext.request.contextPath}/manager">Quay lại</a>
                    <button type="submit">Xem thống kê</button>
                </div>
            </form>
        </main>
    </body>
</html>
