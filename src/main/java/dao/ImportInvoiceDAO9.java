package dao;

import model.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public class ImportInvoiceDAO9 extends DAO {
    private static final String SELECT_INVOICE = """
                SELECT
                    inv.id AS invoiceId,
                    inv.importDate,
                    inv.note,
                    s.id AS supplierId,
                    s.name AS supplierName,
                    s.address AS supplierAddress,
                    s.phone AS supplierPhone,
                    s.email AS supplierEmail,
                    s.taxCode AS supplierTaxCode,
                    s.description AS supplierDescription,
                    st.id AS staffId,
                    st.staffCode,
                    st.position,
                    st.salaryCoefficient,
                    mem.name AS staffName,
                    m.id AS materialId,
                    m.name AS materialName,
                    m.unit AS materialUnit,
                    m.referencePrice,
                    i.id AS itemId,
                    i.quantity,
                    i.importPrice
                FROM tblImportInvoice9 inv
                JOIN tblSupplier9 s
                    ON s.id = inv.supplierId
                JOIN tblStaff9 st
                    ON st.id = inv.storekeeperId
                JOIN tblMember9 mem
                    ON mem.id = st.id
                LEFT JOIN tblImportInvoiceItem9 i
                    ON i.importInvoiceId = inv.id
                LEFT JOIN tblMaterial9 m
                    ON m.id = i.materialId
            """;

    public ImportInvoiceDAO9() {
        super();
    }

    public ImportInvoice9[] getImportInvoices(int supplierId, LocalDate startDate, LocalDate endDate)
            throws SQLException {
        validateDateRange(startDate, endDate);
        String sql = SELECT_INVOICE + """
                WHERE inv.supplierId = ? AND inv.importDate >= ? AND inv.importDate < ?
                ORDER BY
                    inv.importDate ASC,
                    inv.id ASC,
                    i.id
                """;
        // LinkedHashMap gom các dòng cùng hóa đơn và giữ thứ tự ngày, mã do SQL sắp xếp
        Map<Integer, ImportInvoice9> result = new LinkedHashMap<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setObject(2, startDate.atStartOfDay());
            // Lọc trước đầu ngày kế tiếp để bao gồm trọn ngày kết thúc.
            ps.setObject(3, endDate.plusDays(1).atStartOfDay());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    addRow(result, rs);
            }
        }
        return result.values().toArray(new ImportInvoice9[0]);
    }

    public ImportInvoice9 getImportInvoiceDetail(int invoiceId) throws SQLException {
        String sql = SELECT_INVOICE + """
                WHERE inv.id = ?
                ORDER BY
                    inv.importDate ASC,
                    inv.id ASC,
                    i.id
                """;
        Map<Integer, ImportInvoice9> result = new LinkedHashMap<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    addRow(result, rs);
            }
        }
        return result.get(invoiceId);
    }

    private void addRow(Map<Integer, ImportInvoice9> result, ResultSet rs) throws SQLException {
        int invoiceId = rs.getInt("invoiceId");
        ImportInvoice9 invoice = result.get(invoiceId);
        // Chỉ ánh xạ thông tin hóa đơn, nhà cung cấp và nhân viên kho ở dòng đầu tiên
        if (invoice == null) {
            invoice = new ImportInvoice9();
            invoice.setId(invoiceId);
            invoice.setImportDate(rs.getObject("importDate", java.time.LocalDateTime.class));
            invoice.setNote(rs.getString("note"));

            Supplier9 supplier = new Supplier9();
            supplier.setId(rs.getInt("supplierId"));
            supplier.setName(rs.getString("supplierName"));
            supplier.setAddress(rs.getString("supplierAddress"));
            supplier.setPhone(rs.getString("supplierPhone"));
            supplier.setEmail(rs.getString("supplierEmail"));
            supplier.setTaxCode(rs.getString("supplierTaxCode"));
            supplier.setDescription(rs.getString("supplierDescription"));
            invoice.setSupplier(supplier);

            Storekeeper9 storekeeper = new Storekeeper9();
            storekeeper.setId(rs.getInt("staffId"));
            storekeeper.setName(rs.getString("staffName"));
            storekeeper.setStaffCode(rs.getString("staffCode"));
            storekeeper.setPosition(rs.getString("position"));
            storekeeper.setSalaryCoefficient(rs.getBigDecimal("salaryCoefficient"));
            invoice.setStorekeeper(storekeeper);
            result.put(invoiceId, invoice);
        }
        // LEFT JOIN vẫn trả hóa đơn rỗng; chỉ gắn chi tiết khi dòng có itemId
        if (rs.getObject("itemId") != null) {
            Material9 material = new Material9();
            material.setId(rs.getInt("materialId"));
            material.setName(rs.getString("materialName"));
            material.setUnit(rs.getString("materialUnit"));
            material.setReferencePrice(rs.getBigDecimal("referencePrice"));
            ImportInvoiceItem9 item = new ImportInvoiceItem9();
            item.setId(rs.getInt("itemId"));
            item.setQuantity(rs.getBigDecimal("quantity"));
            item.setImportPrice(rs.getBigDecimal("importPrice"));
            item.setMaterial(material);
            invoice.addImportInvoiceItem(item);
        }
    }
}
