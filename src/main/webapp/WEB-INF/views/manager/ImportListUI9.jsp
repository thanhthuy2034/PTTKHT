<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN" />
<fmt:parseDate value="${startDate}" pattern="yyyy-MM-dd" var="startDateValue" />
<fmt:parseDate value="${endDate}" pattern="yyyy-MM-dd" var="endDateValue" />

<!doctype html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>
            Danh sách các lần nhập
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/restman.css">
    </head>
    <body>
        <main class="shell">
            <h1>DANH SÁCH CÁC LẦN NHẬP</h1>
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
            <dl class="details">
                <div>
                    <dt>Nhà cung cấp:</dt>
                    <dd>
                        <c:out value="${supplier.name}"/>
                    </dd>
                </div>
            </dl>
            <div class="table-wrap">
                <table class="data-table import-table">
                    <colgroup>
                        <col class="col-stt">
                        <col class="col-code">
                        <col class="col-date">
                        <col class="col-name">
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
                                Mã HĐ nhập
                            </th>
                            <th>
                                Ngày giờ nhập
                            </th>
                            <th>
                                Nhân viên kho
                            </th>
                            <th>
                                Tổng số lượng
                            </th>
                            <th>
                                Tổng tiền
                            </th>
                            <th>
                                Xem chi tiết
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listImportInvoices}" var="invoice" varStatus="n">
                            <tr>
                                <td class="center">
                                    ${n.count}
                                </td>
                                <td class="center">
                                    PN<fmt:formatNumber value="${invoice.id}" pattern="000"/>
                                </td>
                                <td class="center">
                                    <fmt:parseDate value="${fn:replace(invoice.importDate, 'T', ' ')}"
                                        pattern="yyyy-MM-dd HH:mm" var="importDateValue" />
                                    <fmt:formatDate value="${importDateValue}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                                <td>
                                    <c:out value="${invoice.storekeeper.name}"/>
                                </td>
                                <td class="quantity-total">
                                    <ul class="units">
                                        <c:forEach items="${invoice.totalImportQuantityByUnit}" var="q">
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
                                    <fmt:formatNumber value="${invoice.totalAmount}" maxFractionDigits="5"/>đ
                                </td>
                                <c:url var="detailUrl" value="/supplier-statistics">
                                    <c:param name="report" value="${report}"/>
                                    <c:param name="invoiceId" value="${invoice.id}"/>
                                    <c:param name="supplierId" value="${supplier.id}"/>
                                </c:url>
                                <td class="center">
                                    <a href="<c:out value='${detailUrl}'/>">Xem chi tiết</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <c:if test="${empty listImportInvoices}">
                <p class="notification">
                    Không có hóa đơn nhập trong khoảng thời gian này.
                </p>
            </c:if>
            <div class="toolbar align-end">
                <c:url var="backUrl" value="/supplier-statistics">
                    <c:param name="report" value="${report}"/>
                </c:url>
                <a class="button" href="<c:out value='${backUrl}'/>">Quay lại</a>
            </div>
        </main>
    </body>
</html>
