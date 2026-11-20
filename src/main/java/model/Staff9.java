package model;

import java.math.BigDecimal;

public abstract class Staff9 extends Member9 {
    private String staffCode;
    private String position;
    private BigDecimal salaryCoefficient;

    public Staff9() {
    }

    public String getStaffCode() {
        return staffCode;
    }

    public void setStaffCode(String staffCode) {
        this.staffCode = staffCode;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public BigDecimal getSalaryCoefficient() {
        return salaryCoefficient;
    }

    public void setSalaryCoefficient(BigDecimal salaryCoefficient) {
        this.salaryCoefficient = salaryCoefficient;
    }
}
