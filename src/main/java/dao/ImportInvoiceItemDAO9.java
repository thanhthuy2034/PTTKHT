package dao;

import model.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImportInvoiceItemDAO9 extends DAO {
    public ImportInvoiceItemDAO9() {
        super();
    }

    public ImportInvoiceItem9[] getImportInvoiceItems(int invoiceId) throws SQLException {
        String sql = """
                SELECT
                    i.id,
                    i.quantity,
                    i.importPrice,
                    m.id AS materialId,
                    m.name AS materialName,
                    m.unit AS materialUnit,
                    m.referencePrice
                FROM tblImportInvoiceItem9 i
                JOIN tblMaterial9 m
                    ON m.id = i.materialId
                WHERE i.importInvoiceId = ?
                ORDER BY i.id
                """;
        List<ImportInvoiceItem9> items = new ArrayList<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Material9 material = new Material9();
                    material.setId(rs.getInt("materialId"));
                    material.setName(rs.getString("materialName"));
                    material.setUnit(rs.getString("materialUnit"));
                    material.setReferencePrice(rs.getBigDecimal("referencePrice"));

                    ImportInvoiceItem9 item = new ImportInvoiceItem9();
                    item.setId(rs.getInt("id"));
                    item.setQuantity(rs.getBigDecimal("quantity"));
                    item.setImportPrice(rs.getBigDecimal("importPrice"));
                    item.setMaterial(material);
                    items.add(item);
                }
            }
        }
        return items.toArray(new ImportInvoiceItem9[0]);
    }
}
