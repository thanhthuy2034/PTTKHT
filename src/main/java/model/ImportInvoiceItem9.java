package model;

import java.math.BigDecimal;
import java.util.Objects;

public class ImportInvoiceItem9 {
    private int id;
    private BigDecimal quantity = BigDecimal.ZERO;
    private BigDecimal importPrice = BigDecimal.ZERO;
    private Material9 material;

    public ImportInvoiceItem9() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public BigDecimal getQuantity() {
        return quantity;
    }

    public void setQuantity(BigDecimal quantity) {
        Objects.requireNonNull(quantity, "Quantity is required");
        if (quantity.signum() < 0) {
            throw new IllegalArgumentException("Quantity cannot be negative");
        }
        this.quantity = quantity;
    }

    public BigDecimal getImportPrice() {
        return importPrice;
    }

    public void setImportPrice(BigDecimal importPrice) {
        Objects.requireNonNull(importPrice, "Import price is required");
        if (importPrice.signum() < 0) {
            throw new IllegalArgumentException("Import price cannot be negative");
        }
        this.importPrice = importPrice;
    }

    public BigDecimal getAmount() {
        return quantity.multiply(importPrice);
    }

    public Material9 getMaterial() {
        return material;
    }

    public void setMaterial(Material9 material) {
        this.material = material;
    }
}
