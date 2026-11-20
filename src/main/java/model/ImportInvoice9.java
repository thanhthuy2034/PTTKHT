package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;
import java.util.Objects;

public class ImportInvoice9 {
    private int id;
    private LocalDateTime importDate;
    private String note;
    private Supplier9 supplier;
    private Storekeeper9 storekeeper;
    private List<ImportInvoiceItem9> importInvoiceItems = new ArrayList<>();

    public ImportInvoice9() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDateTime getImportDate() {
        return importDate;
    }

    public void setImportDate(LocalDateTime importDate) {
        this.importDate = importDate;
    }

    public BigDecimal getTotalAmount() {
        // Cộng thành tiền các chi tiết bằng BigDecimal; hóa đơn rỗng có tổng bằng 0
        return importInvoiceItems.stream().map(ImportInvoiceItem9::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Supplier9 getSupplier() {
        return supplier;
    }

    public void setSupplier(Supplier9 supplier) {
        this.supplier = supplier;
    }

    public Storekeeper9 getStorekeeper() {
        return storekeeper;
    }

    public void setStorekeeper(Storekeeper9 storekeeper) {
        this.storekeeper = storekeeper;
    }

    public List<ImportInvoiceItem9> getImportInvoiceItems() {
        return Collections.unmodifiableList(importInvoiceItems);
    }

    public void setImportInvoiceItems(List<ImportInvoiceItem9> importInvoiceItems) {
        List<ImportInvoiceItem9> copy = new ArrayList<>(Objects.requireNonNull(importInvoiceItems));
        copy.forEach(this::validateItem);
        this.importInvoiceItems = copy;
    }

    public void addImportInvoiceItem(ImportInvoiceItem9 item) {
        validateItem(item);
        importInvoiceItems.add(item);
    }

    private void validateItem(ImportInvoiceItem9 item) {
        Objects.requireNonNull(item, "Invoice item is required");
        Objects.requireNonNull(item.getMaterial(), "Material is required");
        String unit = item.getMaterial().getUnit();
        if (unit == null || unit.isBlank()) {
            throw new IllegalArgumentException("Material unit is required");
        }
    }

    public Map<String, BigDecimal> getTotalImportQuantityByUnit() {
        // Chỉ cộng số lượng cùng đơn vị tính để tránh gộp lẫn kg, lít, chai...
        Map<String, BigDecimal> quantities = new LinkedHashMap<>();
        for (ImportInvoiceItem9 item : importInvoiceItems) {
            quantities.merge(item.getMaterial().getUnit(), item.getQuantity(), BigDecimal::add);
        }
        return Collections.unmodifiableMap(quantities);
    }
}
