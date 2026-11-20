package dao;

import model.SupplierStat9;
import model.Supplier9;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public class SupplierStatDAO9 extends DAO {
    public SupplierStatDAO9() {
        super();
    }

    public SupplierStat9[] getSupplierStatistics(LocalDate startDate, LocalDate endDate) throws SQLException {
        validateDateRange(startDate, endDate);
        // SUM và GROUP BY cộng lượng, tiền nhập theo từng nhà cung cấp và đơn vị tính
        String sql = """
                SELECT
                    s.id AS supplierId,
                    s.name AS supplierName,
                    s.address AS supplierAddress,
                    s.phone AS supplierPhone,
                    s.email AS supplierEmail,
                    s.taxCode AS supplierTaxCode,
                    s.description AS supplierDescription,
                    m.unit AS materialUnit,
                    SUM(i.quantity) AS unitQuantity,
                    SUM(i.quantity * i.importPrice) AS unitAmount
                FROM tblSupplier9 s
                JOIN tblImportInvoice9 inv
                    ON inv.supplierId = s.id
                JOIN tblImportInvoiceItem9 i
                    ON i.importInvoiceId = inv.id
                JOIN tblMaterial9 m
                    ON m.id = i.materialId
                WHERE inv.importDate >= ? AND inv.importDate < ?
                GROUP BY
                    s.id,
                    s.name,
                    s.address,
                    s.phone,
                    s.email,
                    s.taxCode,
                    s.description,
                    m.unit
                ORDER BY
                    s.id,
                    m.unit
                """;
        Map<Integer, Supplier9> suppliers = new LinkedHashMap<>();
        Map<Integer, Map<String, BigDecimal>> quantities = new LinkedHashMap<>();
        Map<Integer, BigDecimal> amounts = new LinkedHashMap<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, startDate.atStartOfDay());
            // Cận trên là đầu ngày kế tiếp để lấy đủ mọi thời điểm trong ngày kết thúc
            ps.setObject(2, endDate.plusDays(1).atStartOfDay());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("supplierId");
                    Supplier9 stat = suppliers.get(id);
                    if (stat == null) {
                        stat = new Supplier9();
                        stat.setId(id);
                        stat.setName(rs.getString("supplierName"));
                        stat.setAddress(rs.getString("supplierAddress"));
                        stat.setPhone(rs.getString("supplierPhone"));
                        stat.setEmail(rs.getString("supplierEmail"));
                        stat.setTaxCode(rs.getString("supplierTaxCode"));
                        stat.setDescription(rs.getString("supplierDescription"));
                        suppliers.put(id, stat);
                    }
                    String unit = rs.getString("materialUnit");
                    BigDecimal quantity = rs.getBigDecimal("unitQuantity");
                    BigDecimal money = rs.getBigDecimal("unitAmount");
                    quantities.computeIfAbsent(id, key -> new LinkedHashMap<>())
                            .merge(unit, quantity, BigDecimal::add);
                    amounts.merge(id, money, BigDecimal::add);
                }
            }
        }
        List<SupplierStat9> result = new ArrayList<>();
        for (Supplier9 supplier : suppliers.values()) {
            SupplierStat9 stat = new SupplierStat9(amounts.get(supplier.getId()),
                    quantities.get(supplier.getId()));
            stat.setId(supplier.getId());
            stat.setName(supplier.getName());
            stat.setAddress(supplier.getAddress());
            stat.setPhone(supplier.getPhone());
            stat.setEmail(supplier.getEmail());
            stat.setTaxCode(supplier.getTaxCode());
            stat.setDescription(supplier.getDescription());
            result.add(stat);
        }
        // Xếp tổng tiền nhập giảm dần; nếu bằng nhau thì xếp theo mã nhà cung cấp tăng dần
        return result.stream()
                .sorted(Comparator.comparing(SupplierStat9::getTotalImportAmount).reversed()
                        .thenComparingInt(SupplierStat9::getId))
                .toArray(SupplierStat9[]::new);
    }
}
