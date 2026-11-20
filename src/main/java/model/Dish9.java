package model;

import java.math.BigDecimal;

public class Dish9 {
    private int id;
    private String name;
    private String unit;
    private BigDecimal price;
    private String image;
    private String description;
    private String status;
    private DishCategory9 dishCategory;

    public Dish9() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isDiscontinued() {
        return status != null && ("Ngừng phục vụ".equalsIgnoreCase(status.strip())
                || "Ngưng phục vụ".equalsIgnoreCase(status.strip()));
    }

    public DishCategory9 getDishCategory() {
        return dishCategory;
    }

    public void setDishCategory(DishCategory9 dishCategory) {
        this.dishCategory = dishCategory;
    }
}
