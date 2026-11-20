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
            Chi tiết hóa đơn nhập nguyên liệu
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/restman.css">
    </head>
    <body>
        <main class="shell">
            <h1>CHI TIẾT HÓA ĐƠN NHẬP NGUYÊN LIỆU</h1>
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
                    <dt>Mã hóa đơn nhập:</dt>
                    <dd>
                        PN<fmt:formatNumber value="${invoice.id}" pattern="000"/>
                    </dd>
                </div>
                <div>
                    <dt>Ngày giờ nhập:</dt>
                    <dd>
                        <fmt:parseDate value="${fn:replace(invoice.importDate, 'T', ' ')}"
                            pattern="yyyy-MM-dd HH:mm" var="importDateValue"/>
                        <fmt:formatDate value="${importDateValue}" pattern="dd/MM/yyyy HH:mm"/>
                    </dd>
                </div>
                <div>
                    <dt>Nhà cung cấp:</dt>
                    <dd>
                        <c:out value="${invoice.supplier.name}"/>
                    </dd>
                </div>
                <div>
                    <dt>Nhân viên kho:</dt>
                    <dd>
                        <c:out value="${invoice.storekeeper.name}"/>
                    </dd>
                </div>
            </dl>
            <h2>Danh sách nguyên liệu nhập</h2>
            <div class="table-wrap">
                <table class="data-table invoice-table">
                    <colgroup>
                        <col class="col-stt">
                        <col class="col-code">
                        <col class="col-name">
                        <col class="col-unit">
                        <col class="col-quantity">
                        <col class="col-price">
                        <col class="col-amount">
                    </colgroup>
                    <thead>
                        <tr>
                            <th>
                                STT
                            </th>
                            <th>
                                Mã NL
                            </th>
                            <th>
                                Tên nguyên liệu
                            </th>
                            <th>
                                Đơn vị tính
                            </th>
                            <th>
                                Số lượng
                            </th>
                            <th>
                                Đơn giá
                            </th>
                            <th>
                                Thành tiền
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listImportItems}" var="item" varStatus="n">
                            <tr>
                                <td class="center">
                                    ${n.count}
                                </td>
                                <td class="center">
                                    NL<fmt:formatNumber value="${item.material.id}" pattern="00"/>
                                </td>
                                <td>
                                    <c:out value="${item.material.name}"/>
                                </td>
                                <td class="center">
                                    <c:out value="${item.material.unit}"/>
                                </td>
                                <td class="money">
                                    <fmt:formatNumber value="${item.quantity}" maxFractionDigits="3"/>
                                </td>
                                <td class="money">
                                    <fmt:formatNumber value="${item.importPrice}" maxFractionDigits="5"/>đ
                                </td>
                                <td class="money">
                                    <fmt:formatNumber value="${item.amount}" maxFractionDigits="5"/>đ
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <section class="invoice-summary">
                <h2>Tổng số lượng nhập theo đơn vị tính</h2>
                <table class="quantity-summary">
                    <thead>
                        <tr>
                            <th>
                                Đơn vị tính
                            </th>
                            <th>
                                Tổng số lượng
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${invoice.totalImportQuantityByUnit}" var="q">
                            <tr>
                                <td class="center">
                                    <c:out value="${q.key}"/>
                                </td>
                                <td class="quantity-total">
                                    <fmt:formatNumber value="${q.value}" maxFractionDigits="3"/>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <p class="summary">
                    Tổng tiền hóa đơn: <fmt:formatNumber value="${invoice.totalAmount}" maxFractionDigits="5"/>đ
                </p>
            </section>
            <div class="toolbar align-end">
                <c:url var="backUrl" value="/supplier-statistics">
                    <c:param name="report" value="${report}"/>
                    <c:param name="supplierId" value="${invoice.supplier.id}"/>
                </c:url>
                <a class="button" href="<c:out value='${backUrl}'/>">Quay lại</a>
            </div>
        </main>
    </body>
</html>
