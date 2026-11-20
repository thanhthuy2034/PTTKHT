package model;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Collections;
import java.util.Objects;

public class SupplierStat9 extends Supplier9 {
    private final BigDecimal totalImportAmount;
    private final Map<String, BigDecimal> totalImportQuantityByUnit;

    /** Read-only snapshot of aggregates obtained by the DAO for one date range. */
    public SupplierStat9(BigDecimal totalImportAmount, Map<String, BigDecimal> quantities) {
        this.totalImportAmount = Objects.requireNonNull(totalImportAmount);
        Map<String, BigDecimal> copy = new LinkedHashMap<>(Objects.requireNonNull(quantities));
        if (totalImportAmount.signum() < 0 || copy.entrySet().stream().anyMatch(entry ->
                entry.getKey() == null || entry.getKey().isBlank() || entry.getValue() == null
                        || entry.getValue().signum() < 0)) {
            throw new IllegalArgumentException("Invalid supplier aggregates");
        }
        this.totalImportQuantityByUnit = Collections.unmodifiableMap(copy);
    }

    public BigDecimal getTotalImportAmount() {
        return totalImportAmount;
    }

    public Map<String, BigDecimal> getTotalImportQuantityByUnit() {
        return totalImportQuantityByUnit;
    }
}
