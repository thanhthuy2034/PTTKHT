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
            Chi tiết món ăn
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/restman.css">
    </head>
    <body>
        <main class="shell dish-page">
            <h1>CHI TIẾT MÓN ĂN</h1>
            <c:if test="${not empty notification}">
                <div class="notification">
                    <c:out value="${notification}"/>
                </div>
            </c:if>
            <c:if test="${not empty dish}">
                <section class="dish-detail">
                    <div>
                        <c:choose>
                            <c:when test="${not empty dish.image}">
                                <img
                                    class="dish-image"
                                    src="${pageContext.request.contextPath}/assets/<c:out value='${dish.image}'/>"
                                    alt="<c:out value='${dish.name}'/>">
                            </c:when>
                            <c:otherwise>
                                <p>Chưa có ảnh món ăn.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <table class="dish-info" aria-label="Thông tin món ăn">
                            <tbody>
                                <tr>
                                    <th scope="row">
                                        Mã món:
                                    </th>
                                    <td class="dish-value">
                                        MA<fmt:formatNumber value="${dish.id}" pattern="00"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row">
                                        Tên món:
                                    </th>
                                    <td class="dish-value">
                                        <c:out value="${dish.name}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row">
                                        Danh mục:
                                    </th>
                                    <td class="dish-value">
                                        <c:out value="${dish.dishCategory.name}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row">
                                        Đơn vị tính:
                                    </th>
                                    <td class="dish-value">
                                        <c:out value="${dish.unit}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row">
                                        Đơn giá:
                                    </th>
                                    <td class="dish-value">
                                        <fmt:formatNumber value="${dish.price}" maxFractionDigits="5"/>đ
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row">
                                        Trạng thái:
                                    </th>
                                    <td class="dish-value">
                                        <c:out value="${dish.status}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row">
                                        Mô tả:
                                    </th>
                                    <td class="dish-description"><c:out value="${dish.description}"/></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>
            </c:if>
            <div class="toolbar spaced align-end">
                <c:url var="backUrl" value="/dishes">
                    <c:if test="${not empty keyword}">
                        <c:param name="q" value="${keyword}"/>
                    </c:if>
                </c:url>
                <a class="button" href="<c:out value='${backUrl}'/>">Quay lại</a>
            </div>
        </main>
    </body>
</html>
