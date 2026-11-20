<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<fmt:parseDate value="${startDate}" pattern="yyyy-MM-dd" var="startDateValue" />
<fmt:parseDate value="${endDate}" pattern="yyyy-MM-dd" var="endDateValue" />

<!doctype html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>
            Thống kê nhà cung cấp theo lượng nhập
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/restman.css">
    </head>
    <body>
        <main class="shell">
            <h1>THỐNG KÊ NHÀ CUNG CẤP THEO LƯỢNG NHẬP</h1>
            <dl class="period" aria-label="Khoảng thời gian thống kê">
                <div>
                    <dt>Ngày bắt đầu:</dt>
                    <dd>
                        <fmt:formatDate value="${startDateValue}" pattern="dd/MM/yyyy"/>
                    </dd>
                </div>
                <div>
                    <dt>Ngày kết thúc:</dt>
                    <dd>
                        <fmt:formatDate value="${endDateValue}" pattern="dd/MM/yyyy"/>
                    </dd>
                </div>
            </dl>
            <div class="table-wrap">
                <table class="data-table supplier-table">
                    <colgroup>
                        <col class="col-stt">
                        <col class="col-code">
                        <col class="col-name">
                        <col class="col-address">
                        <col class="col-phone">
                        <col class="col-quantity">
                        <col class="col-amount">
                        <col class="col-action">
                    </colgroup>
                    <thead>
                        <tr>
                            <th>
                                STT
                            </th>
                            <th>
                                Mã NCC
                            </th>
                            <th>
                                Tên NCC
                            </th>
                            <th>
                                Địa chỉ
                            </th>
                            <th>
                                Điện thoại
                            </th>
                            <th>
                                Tổng số lượng
                            </th>
                            <th>
                                Tổng tiền nhập
                            </th>
                            <th>
                                Xem chi tiết
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listSupplierStats}" var="stat" varStatus="n">
                            <tr>
                                <td class="center">
                                    ${n.count}
                                </td>
                                <td class="center">
                                    NCC<fmt:formatNumber value="${stat.id}" pattern="00"/>
                                </td>
                                <td>
                                    <c:out value="${stat.name}"/>
                                </td>
                                <td>
                                    <c:out value="${stat.address}"/>
                                </td>
                                <td>
                                    <c:out value="${stat.phone}"/>
                                </td>
                                <td class="quantity-total">
                                    <ul class="units">
                                        <c:forEach items="${stat.totalImportQuantityByUnit}" var="q">
                                            <li>
                                                <span>
                                                    <fmt:formatNumber value="${q.value}" maxFractionDigits="3"/>
                                                </span>
                                                <span>
                                                    <c:out value="${q.key}"/>
                                                </span>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </td>
                                <td class="money">
                                    <fmt:formatNumber value="${stat.totalImportAmount}" maxFractionDigits="5"/>đ
                                </td>
                                <c:url var="importUrl" value="/supplier-statistics">
                                    <c:param name="report" value="${report}"/>
                                    <c:param name="supplierId" value="${stat.id}"/>
                                </c:url>
                                <td class="center">
                                    <a href="<c:out value='${importUrl}'/>">Xem chi tiết</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <c:if test="${empty listSupplierStats}">
                <p class="notification">
                    Không có dữ liệu nhập trong khoảng thời gian này.
                </p>
            </c:if>
            <div class="toolbar align-end">
                <c:url var="backUrl" value="/supplier-statistics/conditions">
                    <c:param name="report" value="${report}"/>
                </c:url>
                <a class="button" href="<c:out value='${backUrl}'/>">Quay lại</a>
            </div>
        </main>
    </body>
</html>
