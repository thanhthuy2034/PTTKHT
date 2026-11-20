<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />

<!doctype html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>
            Tìm kiếm món ăn
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/restman.css">
    </head>
    <body>
        <main class="shell">
            <h1>TÌM KIẾM MÓN ĂN</h1>
            <form class="form-row" action="${pageContext.request.contextPath}/dishes" method="get">
                <label for="keyword">Tên món ăn:</label>
                <input
                    id="keyword"
                    name="q"
                    value="<c:out value='${keyword}'/>"
                    maxlength="150"
                    required>
                <button type="submit">Tìm kiếm</button>
            </form>
            <c:if test="${not empty notification}">
                <div class="notification">
                    <c:out value="${notification}"/>
                </div>
            </c:if>
            <h2>Kết quả tìm kiếm</h2>
            <div class="table-wrap">
                <table class="data-table dish-table">
                    <colgroup>
                        <col class="col-stt">
                        <col class="col-code">
                        <col class="col-name">
                        <col class="col-category">
                        <col class="col-unit">
                        <col class="col-amount">
                        <col class="col-image">
                        <col class="col-action">
                    </colgroup>
                    <thead>
                        <tr>
                            <th>
                                STT
                            </th>
                            <th>
                                Mã món
                            </th>
                            <th>
                                Tên món
                            </th>
                            <th>
                                Danh mục
                            </th>
                            <th>
                                Đơn vị tính
                            </th>
                            <th>
                                Đơn giá
                            </th>
                            <th>
                                Hình ảnh
                            </th>
                            <th>
                                Xem chi tiết
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listDishes}" var="dish" varStatus="n">
                            <tr>
                                <td class="center">
                                    ${n.count}
                                </td>
                                <td class="center">
                                    MA<fmt:formatNumber value="${dish.id}" pattern="00"/>
                                </td>
                                <td>
                                    <c:out value="${dish.name}"/>
                                </td>
                                <td>
                                    <c:out value="${dish.dishCategory.name}"/>
                                </td>
                                <td class="center">
                                    <c:out value="${dish.unit}"/>
                                </td>
                                <td class="money">
                                    <fmt:formatNumber value="${dish.price}" maxFractionDigits="5"/>đ
                                </td>
                                <td class="center">
                                    <c:choose>
                                        <c:when test="${not empty dish.image}">
                                            <img
                                                class="dish-thumbnail"
                                                src="${pageContext.request.contextPath}/assets/<c:out value='${dish.image}'/>"
                                                alt="<c:out value='${dish.name}'/>">
                                        </c:when>
                                        <c:otherwise>
                                            Chưa có ảnh
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <c:url var="detailUrl" value="/dishes">
                                    <c:param name="id" value="${dish.id}"/>
                                    <c:param name="q" value="${keyword}"/>
                                </c:url>
                                <td class="center">
                                    <a href="<c:out value='${detailUrl}'/>">Xem chi tiết</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="toolbar align-end">
                <c:url var="backUrl" value="/customer">
                </c:url>
                <a class="button" href="<c:out value='${backUrl}'/>">Quay lại</a>
            </div>
        </main>
    </body>
</html>
