package controller;

import dao.*;
import model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(urlPatterns = { "/supplier-statistics", "/supplier-statistics/conditions" })
public class SupplierStatisticsServlet9 extends HttpServlet {
    private static final String REPORTS = SupplierStatisticsServlet9.class.getName() + ".reports";
    private static final SecureRandom RANDOM = new SecureRandom();
    private SupplierStatDAO9 supplierStatDAO;
    private ImportInvoiceDAO9 importInvoiceDAO;
    private ImportInvoiceItemDAO9 importInvoiceItemDAO;

    /** Immutable conditions for one report, isolated from reports opened in other tabs. */
    private static final class ReportRange {
        private final LocalDate startDate;
        private final LocalDate endDate;

        private ReportRange(LocalDate startDate, LocalDate endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }

    @Override
    public void init() {
        supplierStatDAO = new SupplierStatDAO9();
        importInvoiceDAO = new ImportInvoiceDAO9();
        importInvoiceItemDAO = new ImportInvoiceItemDAO9();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!"/supplier-statistics".equals(request.getServletPath())) {
            response.setHeader("Allow", "GET, HEAD");
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        HttpSession session = request.getSession(false);
        String csrf = request.getParameter("csrfToken");
        // Đối chiếu CSRF token với phiên trước khi nhận điều kiện thống kê
        if (session == null || csrf == null || !csrf.equals(session.getAttribute("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Phiên làm việc không hợp lệ. Vui lòng tải lại trang.");
            return;
        }
        request.setAttribute("startDate", request.getParameter("startDate"));
        request.setAttribute("endDate", request.getParameter("endDate"));
        String type = request.getParameter("statisticsType");
        if (!"supplier".equals(type)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("notification", "Loại thống kê này chưa triển khai. Vui lòng chọn nhà cung cấp theo lượng nhập.");
            showStatisticsCondition(request, response);
            return;
        }
        try {
            LocalDate start = LocalDate.parse(request.getParameter("startDate"));
            LocalDate end = LocalDate.parse(request.getParameter("endDate"));
            // Kiểm tra thứ tự ngày, giới hạn năm và ngày kết thúc không vượt hôm nay
            DAO.validateDateRange(start, end);
            String report = saveRange(session, new ReportRange(start, end));
            // HTTP 303 chuyển sang GET để tải lại kết quả không gửi lại biểu mẫu POST
            response.setStatus(HttpServletResponse.SC_SEE_OTHER);
            response.setHeader("Location", request.getContextPath()
                    + "/supplier-statistics?report=" + report);
        } catch (DateTimeParseException | NullPointerException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("notification", "Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc hợp lệ.");
            showStatisticsCondition(request, response);
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("notification", ex.getMessage());
            showStatisticsCondition(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String report = request.getParameter("report");
        
        boolean conditions = "/supplier-statistics/conditions".equals(request.getServletPath());

        boolean invoiceDetail = request.getParameter("invoiceId") != null;

        boolean importList = request.getParameter("supplierId") != null;

        // Khôi phục khoảng ngày từ report trong phiên; mã hết hạn thì yêu cầu chọn lại
        ReportRange range = findRange(request.getSession(false), report);
        if (report != null && range == null) {
            response.setStatus(HttpServletResponse.SC_GONE);
            request.setAttribute("notification", "Điều kiện thống kê đã hết hạn. Vui lòng chọn lại khoảng thời gian.");
            showStatisticsCondition(request, response);
            return;
        }
        if (range != null) {
            request.setAttribute("report", report);
            request.setAttribute("startDate", range.startDate);
            request.setAttribute("endDate", range.endDate);
        }
        if (conditions || (report == null && !invoiceDetail && !importList)) {
            showStatisticsCondition(request, response);
            return;
        }
        if (range == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("notification", "Vui lòng chọn điều kiện thống kê trước khi xem kết quả.");
            showStatisticsCondition(request, response);
            return;
        }
        try {
            // Ưu tiên chi tiết hóa đơn, rồi danh sách nhập; còn lại là thống kê nhà cung cấp
            if (invoiceDetail) {
                viewInvoiceDetail(request, response, range);
            } else if (importList) {
                viewImportList(request, response, range);
            } else {
                request.setAttribute("listSupplierStats",
                        supplierStatDAO.getSupplierStatistics(range.startDate, range.endDate));
                show(request, response, "/WEB-INF/views/manager/SupplierStatisticsUI9.jsp");
            }
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("notification", "Tham số xem thống kê không hợp lệ.");
            showStatisticsCondition(request, response);
        } catch (SQLException ex) {
            getServletContext().log("Supplier statistics lookup failed", ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("notification", "Không thể lấy dữ liệu thống kê. Vui lòng thử lại.");
            showStatisticsCondition(request, response);
        }
    }

    private void showStatisticsCondition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        synchronized (session) {
            if (session.getAttribute("csrfToken") == null) {
                byte[] bytes = new byte[32];
                RANDOM.nextBytes(bytes);
                session.setAttribute("csrfToken", Base64.getUrlEncoder().withoutPadding().encodeToString(bytes));
            }
        }
        request.setAttribute("today", LocalDate.now());
        show(request, response, "/WEB-INF/views/manager/StatisticsConditionUI9.jsp");
    }

    private void viewImportList(HttpServletRequest request, HttpServletResponse response, ReportRange range)
            throws SQLException, ServletException, IOException {
        int supplierId = positiveId(request.getParameter("supplierId"));
        // Chỉ cho xem các lần nhập của nhà cung cấp có trong kết quả thống kê đã chọn
        Supplier9 supplier = Arrays.stream(supplierStatDAO.getSupplierStatistics(range.startDate, range.endDate))
                .filter(stat -> stat.getId() == supplierId).findFirst().orElse(null);
        if (supplier == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            request.setAttribute("notification", "Nhà cung cấp không nằm trong kết quả thống kê đã chọn.");
            showStatisticsCondition(request, response);
            return;
        }
        request.setAttribute("supplier", supplier);
        request.setAttribute("listImportInvoices",
                importInvoiceDAO.getImportInvoices(supplierId, range.startDate, range.endDate));
        show(request, response, "/WEB-INF/views/manager/ImportListUI9.jsp");
    }

    private void viewInvoiceDetail(HttpServletRequest request, HttpServletResponse response, ReportRange range)
            throws SQLException, ServletException, IOException {
        int invoiceId = positiveId(request.getParameter("invoiceId"));
        int supplierId = positiveId(request.getParameter("supplierId"));
        ImportInvoice9 invoice = importInvoiceDAO.getImportInvoiceDetail(invoiceId);
        // Đối chiếu hóa đơn với cả nhà cung cấp và khoảng ngày để chặn URL sai phạm vi
        if (invoice == null || invoice.getSupplier().getId() != supplierId
                || invoice.getImportDate().toLocalDate().isBefore(range.startDate)
                || invoice.getImportDate().toLocalDate().isAfter(range.endDate)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy hóa đơn trong nhà cung cấp và khoảng thời gian đã chọn.");
            return;
        }
        ImportInvoiceItem9[] items = importInvoiceItemDAO.getImportInvoiceItems(invoiceId);
        invoice.setImportInvoiceItems(Arrays.asList(items));
        request.setAttribute("invoice", invoice);
        request.setAttribute("listImportItems", items);
        show(request, response, "/WEB-INF/views/manager/ImportInvoiceDetailUI9.jsp");
    }

    private int positiveId(String value) {
        int id = Integer.parseInt(value);
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid ID");
        }
        return id;
    }

    @SuppressWarnings("unchecked")
    private String saveRange(HttpSession session, ReportRange range) {
        // Lưu mỗi khoảng ngày bằng mã riêng trong phiên để các tab không ghi đè điều kiện nhau
        synchronized (session) {
            Map<String, ReportRange> reports = (Map<String, ReportRange>) session.getAttribute(REPORTS);
            if (reports == null) {
                reports = new LinkedHashMap<>();
                session.setAttribute(REPORTS, reports);
            }
            
            if (reports.size() >= 20) {
                reports.remove(reports.keySet().iterator().next());
            }
            String token;
            do {
                byte[] bytes = new byte[9];
                RANDOM.nextBytes(bytes);
                token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            } while (reports.containsKey(token));
            reports.put(token, range);
            return token;
        }
    }

    @SuppressWarnings("unchecked")
    private ReportRange findRange(HttpSession session, String token) {
        // Chỉ tra mã báo cáo trong phiên hiện tại, không nhận khoảng ngày từ URL
        if (session == null || token == null) {
            return null;
        }
        synchronized (session) {
            Map<String, ReportRange> reports = (Map<String, ReportRange>) session.getAttribute(REPORTS);
            return reports == null ? null : reports.get(token);
        }
    }

    private void show(HttpServletRequest request, HttpServletResponse response, String file)
            throws ServletException, IOException {
        // Chuyển nội bộ sang JSP, giữ dữ liệu và điều kiện thống kê trên request.
        request.getRequestDispatcher(file).forward(request, response);
    }

}
