# RestMan

Bài tập lớn môn Phân tích và Thiết kế hệ thống thông tin. Ứng dụng dùng **Java 17, Tomcat 9 (`javax.servlet`), JSP/JSTL, JDBC/MySQL 8 và Maven WAR**.

Demo chỉ có hai module, truy cập trực tiếp với giả định bước đăng nhập đã hoàn thành:

- **Customer:** tìm kiếm theo tên và xem chi tiết món ăn.
- **Manager:** thống kê nhà cung cấp theo khoảng ngày, xem danh sách lần nhập và chi tiết phiếu nhập.

Không triển khai đăng nhập, đăng ký, đăng xuất, phân quyền tài khoản hoặc API.

## Cấu trúc và thiết kế

```text
RestMan/
├── .gitignore
├── pom.xml
├── README.md
├── Start-RestMan.ps1
├── restman-db.example.properties
├── sql/
│   ├── 01_schema.sql
│   └── 02_demo_data.sql
└── src/main/
    ├── java/
    │   ├── model/                 # Thực thể và phép tính nghiệp vụ
    │   ├── dao/                   # JDBC, truy vấn có tham số
    │   └── controller/            # Servlet, filter, vòng đời JDBC
    └── webapp/
        ├── META-INF/context.xml
        ├── WEB-INF/
        │   ├── web.xml
        │   └── views/
        │       ├── customer/      # 3 JSP
        │       └── manager/       # 5 JSP
        └── assets/                # CSS và 20 ảnh món ăn
```

Kiến trúc bốn tầng **Model – DAO – Controller (Servlet) – View (JSP)** bám sát mục 5.1/Hình 5.1 của tài liệu mẫu `7.pdf`, điều chỉnh cho Maven: Java đặt trong `src/main/java`, JSP trong `src/main/webapp/WEB-INF/views` theo module, thư viện khai báo trong `pom.xml`. Maven tự đóng gói thư viện vào `WEB-INF/lib`; Servlet API do Tomcat cung cấp. JSP chỉ được mở qua Servlet.

Số lượng nhập được tổng hợp **riêng theo từng đơn vị tính**; tiền dùng `DECIMAL` trong MySQL và `BigDecimal` trong Java. Khoảng thống kê gồm cả ngày bắt đầu và ngày kết thúc. Biểu mẫu kiểm tra dữ liệu và CSRF, dùng luồng **POST → HTTP 303 → GET**. Session chỉ giữ token biểu mẫu và điều kiện theo mã báo cáo riêng cho từng tab, tối đa 20 báo cáo; session hết hạn sau 20 phút không hoạt động.

Schema giữ 19 bảng của ERD; các bảng ngoài hai module chưa có chức năng tương ứng. Bản ghi thành viên mẫu phục vụ liên kết dữ liệu ERD, dùng dấu `!LOGIN_DISABLED!` thay cho mật khẩu đăng nhập.

## 1. Khởi tạo MySQL 8

Cần JDK 17, Maven 3.9+, MySQL 8.0+ và Tomcat **9**. Chạy MySQL client từ thư mục dự án, nhập mật khẩu tại lời nhắc:

```cmd
mysql --default-character-set=utf8mb4 -u YOUR_DB_USER -p
```

Trong MySQL client:

```sql
SOURCE sql/01_schema.sql;
SOURCE sql/02_demo_data.sql;
```

Tài khoản khởi tạo cần quyền tạo database `restman`, bảng, routine và bảng tạm. SQL dùng collation `utf8mb4_0900_ai_ci` của MySQL 8. Dữ liệu mẫu gồm **20 món ăn, 5 danh mục, 6 nhà cung cấp, 18 nguyên liệu, 30 phiếu nhập và 84 dòng chi tiết**, trong tháng 01–09/2026. Có món hết hàng và ngừng phục vụ để kiểm tra các trường hợp tương ứng.

Có thể chạy lại hai file SQL trên schema tương thích: dòng mẫu đã khớp được giữ nguyên, dòng thiếu được bổ sung; nếu trùng ID hoặc định danh với dữ liệu khác, seed báo lỗi và rollback, không sửa/xóa dữ liệu nghiệp vụ hiện có. Không dùng tùy chọn `--force`. Sao lưu trước nếu database đã có dữ liệu riêng. Để tạo bộ demo từ đầu, dùng một database `restman` mới trên môi trường local riêng.

## 2. Cấu hình kết nối

Sao chép `restman-db.example.properties` thành `restman-db.local.properties`, đặt **ngoài WAR** (ví dụ trong thư mục dự án local hoặc một thư mục cấu hình riêng). Điền URL JDBC, tên người dùng và mật khẩu MySQL trên máy của bạn. Nên dùng tài khoản chạy ứng dụng chỉ có quyền `SELECT` trên `restman.*`.

Trong cửa sổ **Command Prompt (CMD)** sẽ dùng chạy Tomcat, đặt đường dẫn tuyệt đối:

```cmd
set "RESTMAN_DB_CONFIG=C:\path\to\restman-db.local.properties"
```

Khi chạy bằng `Start-RestMan.ps1`, có thể bỏ qua lệnh `set` này nếu file nằm ở `restman-db.local.properties` trong thư mục dự án hoặc `.tomcat/conf/restman-db.local.properties`. Script ưu tiên biến `RESTMAN_DB_CONFIG`, sau đó file ở thư mục dự án, cuối cùng file trong `.tomcat/conf`; không sao chép cấu hình vào WAR và không thay đổi dữ liệu MySQL.

DAO đọc cấu hình từ `RESTMAN_DB_CONFIG` hoặc JVM property `-Drestman.db.config=...` (JVM property được ưu tiên). Các biến `RESTMAN_DB_URL`, `RESTMAN_DB_USER`, `RESTMAN_DB_PASSWORD`, nếu đã đặt, ghi đè giá trị tương ứng trong file. Khi thiếu cấu hình mật khẩu, truy vấn database sẽ báo lỗi; ứng dụng không có mật khẩu mặc định.

File cấu hình dùng UTF-8; trên Windows có thể dùng dấu `/` trong đường dẫn bên trong file properties. Không đặt cấu hình thật trong `src/main/webapp` hoặc `src/main/resources`, vì chúng có thể được đóng gói vào WAR. Không đưa mật khẩu, cấu hình local hoặc bản sao database thật lên Git. Giữ `restman-db.example.properties` với các giá trị hướng dẫn.

## 3. Build WAR bằng Java 17

Mở CMD tại thư mục dự án, thay đường dẫn JDK theo máy:

```cmd
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"
mvn -version
mvn clean package
```

Kiểm tra Maven đang dùng Java 17 và chờ `BUILD SUCCESS`. File triển khai là **`target/restman.war`**. Maven tải dependency khi build lần đầu; không cần chép JAR thủ công. Dự án không kèm bộ test tự động; build kiểm tra biên dịch Java và đóng gói, cần chạy Tomcat để kiểm tra JSP và nghiệp vụ.

## 4. Chạy demo nhanh bằng Start-RestMan.ps1

Sau khi cấu hình MySQL, mở **CMD tại thư mục dự án** và chạy các lệnh sau, thay đường dẫn theo máy:

```cmd
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "CATALINA_HOME=C:\path\to\apache-tomcat-9"
mvn clean package
powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-RestMan.ps1
```

Chỉ chạy lệnh cuối khi Maven báo `BUILD SUCCESS`. Nếu file cấu hình không nằm ở một trong hai vị trí local nêu trên, đặt `RESTMAN_DB_CONFIG` trước khi chạy script. Không cần đặt `CATALINA_BASE`: script dùng `.tomcat/` riêng trong dự án, chuẩn bị cấu hình Tomcat và chép `target/restman.war` vào `.tomcat/webapps/`.

Nếu đang dùng **PowerShell**, có thể truyền trực tiếp đường dẫn JDK và Tomcat:

```powershell
.\Start-RestMan.ps1 -JavaHome 'C:\Program Files\Java\jdk-17' -TomcatHome 'C:\path\to\apache-tomcat-9'
```

Script kiểm tra JDK 17, Tomcat 9, WAR và cổng 8080 trước khi khởi động; nếu cổng bận, script báo lỗi và không dừng tiến trình đang sử dụng cổng. Tomcat chỉ lắng nghe tại `127.0.0.1:8080`. Chờ log `Server startup in [...] milliseconds`, rồi mở hai địa chỉ Customer và Manager ở mục 5. **Giữ cửa sổ chạy mở; nhấn Ctrl+C để dừng demo**. Sau khi sửa source, dừng demo, build lại rồi chạy script lần nữa.

Các file cấu hình MySQL local được giữ nguyên khi chạy lại. `.tomcat/` chứa WAR triển khai, log và cache được sinh lại; thư mục này đã được Git bỏ qua. Không xóa `.tomcat/conf/restman-db.local.properties` nếu đó là nơi bạn lưu cấu hình kết nối.

### Triển khai WAR thủ công trên Tomcat 9 (tùy chọn)

Trong cùng CMD đã đặt `JAVA_HOME` và `RESTMAN_DB_CONFIG`, khai báo thư mục cài Tomcat 9:

```cmd
set "CATALINA_HOME=C:\path\to\apache-tomcat-9"
set "CATALINA_BASE=%CATALINA_HOME%"
```

1. Dừng Tomcat nếu đang chạy bằng `bin\shutdown.bat` hoặc Ctrl+C tại cửa sổ chạy `catalina.bat run`. Chỉ thay WAR khi server đã dừng.
2. Chép `target\restman.war` vào `%CATALINA_BASE%\webapps\restman.war`. Khi cập nhật bản cũ, xóa riêng thư mục bung WAR `webapps\restman` sau khi đã sao lưu nếu có dữ liệu tự đặt bên trong; Tomcat sẽ bung lại từ WAR mới.
3. Chạy Tomcat ở cửa sổ hiện tại:

```cmd
copy /Y target\restman.war "%CATALINA_BASE%\webapps\restman.war"
call "%CATALINA_HOME%\bin\catalina.bat" run
```

Chờ log `Server startup in [...] milliseconds`, giữ cửa sổ mở trong buổi demo. Nếu dùng Tomcat chạy dưới Windows Service, cần cấu hình biến môi trường/JVM property cho chính service; các lệnh `set` trong CMD chỉ áp dụng cho tiến trình chạy từ cửa sổ đó.

Tomcat mặc định dùng cổng 8080. Nếu cổng bận, dừng đúng instance local hoặc sửa Connector trong `conf/server.xml` rồi truy cập cổng tương ứng. Tomcat 10+ dùng `jakarta.servlet`, không tương thích với WAR này.

## 5. Truy cập và kiểm tra demo

- **Customer:** <http://127.0.0.1:8080/restman/customer> → tìm kiếm → nhập `Phở` → xem chi tiết → quay lại. Món ngừng phục vụ không xuất hiện trong kết quả; món hết hàng vẫn xem được thông tin.
- **Manager:** <http://127.0.0.1:8080/restman/manager> → chọn điều kiện → chọn nhà cung cấp, từ `01/01/2026` đến `30/09/2026` → thống kê → danh sách lần nhập → chi tiết phiếu nhập → quay lại.

`/restman/` mặc định mở trang chủ Customer. Không cần nhập tài khoản. Tháng 06/2026 không có phiếu nhập, có thể dùng để kiểm tra thông báo không có dữ liệu. Thử khoảng ngày đảo ngược/ngày tương lai để kiểm tra dữ liệu đầu vào; tải lại trang kết quả sau POST không gửi lại biểu mẫu. Nếu báo cáo hết hạn, chọn lại điều kiện.

Khi kết nối thất bại, kiểm tra MySQL đang chạy, database đã được tạo, đường dẫn cấu hình mà tiến trình Tomcat nhận được và quyền tài khoản; xem log Tomcat để xác định nguyên nhân. Nếu trình duyệt báo từ chối kết nối, kiểm tra Tomcat đã khởi động và đúng cổng.

`target/`, `.tomcat/`, log, cache, cấu hình `*.local.properties` và file IDE được `.gitignore` bỏ qua. Chỉ bàn giao source, tài nguyên, SQL, `pom.xml`, `Start-RestMan.ps1`, file cấu hình mẫu, `.gitignore` và README; không kèm WAR hoặc cấu hình thật trong commit.
