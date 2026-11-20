package dao;

import model.Dish9;
import model.DishCategory9;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DishDAO9 extends DAO {
    private static final String SELECT_DISH = """
                SELECT
                    d.id,
                    d.name,
                    d.unit,
                    d.price,
                    d.image,
                    d.description,
                    d.status,
                    c.id AS categoryId,
                    c.name AS categoryName,
                    c.description AS categoryDescription
                FROM tblDish9 d
                JOIN tblDishCategory9 c
                    ON c.id = d.dishCategoryId
            """;

    public DishDAO9() {
        super();
    }

    public Dish9[] getDishByName(String keyword) throws SQLException {
        String sql = SELECT_DISH + """
                WHERE d.name LIKE ? ESCAPE '!'
                ORDER BY
                    d.name,
                    d.id
                """;
        String term = keyword == null ? "" : keyword.strip();
        term = term.replace("!", "!!").replace("%", "!%").replace("_", "!_");
        List<Dish9> dishes = new ArrayList<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + term + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dishes.add(toDish(rs));
                }
            }
        }
        return dishes.toArray(new Dish9[0]);
    }

    public Dish9 getDishDetail(int dishId) throws SQLException {
        String sql = SELECT_DISH + """
                WHERE d.id = ?
                """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, dishId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? toDish(rs) : null;
            }
        }
    }

    private Dish9 toDish(ResultSet rs) throws SQLException {
        DishCategory9 category = new DishCategory9();
        category.setId(rs.getInt("categoryId"));
        category.setName(rs.getString("categoryName"));
        category.setDescription(rs.getString("categoryDescription"));

        Dish9 dish = new Dish9();
        dish.setId(rs.getInt("id"));
        dish.setName(rs.getString("name"));
        dish.setUnit(rs.getString("unit"));
        dish.setPrice(rs.getBigDecimal("price"));
        dish.setImage(rs.getString("image"));
        dish.setDescription(rs.getString("description"));
        dish.setStatus(rs.getString("status"));
        dish.setDishCategory(category);
        return dish;
    }
}
