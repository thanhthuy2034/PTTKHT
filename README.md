# RestMan

Bài tập lớn môn Phân tích và Thiết kế hệ thống thông tin, dùng **Java 17, Tomcat 9, JSP/JSTL, JDBC/MySQL 8 và Maven**.

- **Customer:** tìm kiếm và xem chi tiết món ăn.
- **Manager:** thống kê nhà cung cấp theo khoảng ngày, xem các lần nhập và chi tiết phiếu nhập.

Demo truy cập trực tiếp, chưa triển khai đăng nhập và phân quyền.

## 1. Chuẩn bị database

Cần **JDK 17, Maven 3.9+, MySQL 8.0+ và Tomcat 9**. Mở CMD tại thư mục dự án:

```cmd
mysql --default-character-set=utf8mb4 -u YOUR_DB_USER -p
```

Trong MySQL client, chạy:

```sql
SOURCE sql/01_schema.sql;
SOURCE sql/02_demo_data.sql;
```

Tài khoản khởi tạo cần quyền tạo database, bảng, routine và bảng tạm. Dữ liệu mẫu nằm trong tháng 01–09/2026.

## 2. Cấu hình MySQL

Sao chép file mẫu tại thư mục dự án (bỏ qua nếu đã có file local):

```cmd
copy restman-db.example.properties restman-db.local.properties
```

Sửa `url`, `username`, `password` theo MySQL trên máy. Nên dùng tài khoản chạy ứng dụng chỉ có quyền `SELECT` trên `restman.*`.

Script tự tìm cấu hình tại `restman-db.local.properties` hoặc `.tomcat/conf/restman-db.local.properties`. Nếu lưu nơi khác, đặt `RESTMAN_DB_CONFIG` tới đường dẫn tuyệt đối. Giữ cấu hình thật ngoài WAR và không đưa lên Git.

## 3. Build và chạy

Trong **CMD tại thư mục dự án**, chạy các lệnh dưới đây. Đường dẫn Tomcat là vị trí đã kiểm tra trên máy hiện tại; nếu dùng máy khác, thay đường dẫn JDK và Tomcat cho phù hợp. Thư mục Tomcat phải chứa `bin\catalina.bat`.

```cmd
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "CATALINA_HOME=%USERPROFILE%\apache-tomcat-9.0.115-windows-x64\apache-tomcat-9.0.115"
mvn clean package
powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-RestMan.ps1
```

Chỉ chạy script khi Maven báo `BUILD SUCCESS`. WAR được tạo tại `target/restman.war`; script triển khai vào `.tomcat/` và dùng cổng **8080**. Tomcat 10+ không tương thích.

Chờ log `Server startup in [...] milliseconds`, rồi mở:

- **Customer:** <http://localhost:8080/restman/customer>
- **Manager:** <http://localhost:8080/restman/manager>

Thử tìm món `Phở` hoặc thống kê từ `01/01/2026` đến `30/09/2026`. Giữ cửa sổ CMD mở; nhấn **Ctrl+C** để dừng. Sau khi sửa source, dừng ứng dụng, build lại và chạy script.

Nếu lỗi đường dẫn, kiểm tra `JAVA_HOME` và `CATALINA_HOME`. Nếu cổng 8080 bận, dừng đúng server đang dùng cổng trước khi chạy lại. Nếu lỗi database, kiểm tra MySQL, file cấu hình và log trong `.tomcat/logs/`.

## Cấu trúc chính

- `src/main/java/`: Model, DAO và Controller (Servlet).
- `src/main/webapp/WEB-INF/views/`: giao diện JSP.
- `src/main/webapp/assets/`: CSS và ảnh.
- `sql/`: schema và dữ liệu mẫu.

Dự án chưa có test tự động; Maven kiểm tra biên dịch và đóng gói, cần chạy ứng dụng để kiểm tra JSP và nghiệp vụ.
