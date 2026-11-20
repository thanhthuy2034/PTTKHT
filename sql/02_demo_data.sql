-- Bếp Việt Ba Miền: current demo only. Run 01_schema.sql first.
-- Existing matching rows are kept; missing demo rows are inserted in one transaction.
-- Conflicting IDs/identities abort and roll back; no business row is updated or deleted.
-- 20 dishes, 5 categories, 6 suppliers, 18 materials, 30 invoices, 84 lines.
-- Back up an existing database before seeding. Do not use --force.
SET NAMES utf8mb4;
USE restman;
DROP PROCEDURE IF EXISTS seed_bep_viet_ba_mien9;
DELIMITER $$
CREATE PROCEDURE seed_bep_viet_ba_mien9(IN apply_changes BOOLEAN)
BEGIN
    DECLARE acquired INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS seed_tblMember9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblStaff9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblCustomer9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblDishCategory9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblDish9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblSupplier9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblMaterial9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblImportInvoice9;
        DROP TEMPORARY TABLE IF EXISTS seed_tblImportInvoiceItem9;
        IF acquired = 1 THEN DO RELEASE_LOCK('restman.demo.bep_viet_ba_mien9'); END IF;
        RESIGNAL;
    END;
    SELECT GET_LOCK('restman.demo.bep_viet_ba_mien9',10) INTO acquired;
    IF acquired IS NULL OR acquired <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Another demo seed is running';
    END IF;
    IF @@FOREIGN_KEY_CHECKS <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Foreign-key checks must remain enabled';
    END IF;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    START TRANSACTION;

    -- Fictitious ERD member records only; login is disabled in this demo.
    CREATE TEMPORARY TABLE seed_tblMember9 LIKE tblMember9;
    INSERT INTO seed_tblMember9 (id, username, password, name, role) VALUES
        (
            1,
            'manager_demo',
            '!LOGIN_DISABLED!',
            'Nguyễn Quản Lý',
            'MANAGER'
        ),
        (
            2,
            'storekeeper_demo',
            '!LOGIN_DISABLED!',
            'Nguyễn Văn A',
            'STOREKEEPER'
        ),
        (9001, 'customer',
            '!LOGIN_DISABLED!',
            'Khách hàng mẫu', 'CUSTOMER'),
        (9002, 'manager',
            '!LOGIN_DISABLED!',
            'Quản lý mẫu', 'STAFF'),
        (9003, 'restman_storekeeper_a',
            '!LOGIN_DISABLED!',
            'Nhân viên kho mẫu A', 'STOREKEEPER'),
        (9004, 'restman_storekeeper_b',
            '!LOGIN_DISABLED!',
            'Nhân viên kho mẫu B', 'STAFF');

    CREATE TEMPORARY TABLE seed_tblStaff9 LIKE tblStaff9;
    INSERT INTO seed_tblStaff9 (id, staffCode, position, salaryCoefficient) VALUES
        (1, 'NV001', 'Manager', 2.00),
        (2, 'NV002', 'Storekeeper', 1.60),
        (9002, 'NV-RM-9002', 'Manager', 2.40),
        (9003, 'NV-RM-9003', 'Storekeeper', 1.60),
        (9004, 'NV-RM-9004', 'Storekeeper', 1.80);

    CREATE TEMPORARY TABLE seed_tblCustomer9 LIKE tblCustomer9;
    INSERT INTO seed_tblCustomer9 (id, customerCode, registerDate) VALUES
        (9001, 'KH-RM-9001', '2026-02-01');

    CREATE TEMPORARY TABLE seed_tblDishCategory9 LIKE tblDishCategory9;
    INSERT INTO seed_tblDishCategory9 (id, name, description) VALUES
        ('1', 'Món nước', 'Danh mục món nước của Bếp Việt Ba Miền'),
        ('2', 'Món cơm', 'Danh mục món cơm của Bếp Việt Ba Miền'),
        ('3', 'Món mặn', 'Danh mục món mặn của Bếp Việt Ba Miền'),
        ('4', 'Khai vị', 'Danh mục khai vị của Bếp Việt Ba Miền'),
        ('5', 'Đồ uống', 'Danh mục đồ uống của Bếp Việt Ba Miền');

    CREATE TEMPORARY TABLE seed_tblDish9 LIKE tblDish9;
    INSERT INTO seed_tblDish9 (id, name, unit, price, image, description, status, dishCategoryId) VALUES
        ('1', 'Phở bò', 'Tô', '55000.00', 'dishes/pho-bo.webp', 'Phở bò nước hầm xương, bánh phở mềm, hành lá và rau thơm.', 'Đang bán', '1'),
        ('2', 'Phở gà', 'Tô', '50000.00', 'dishes/pho-ga.webp', 'Phở gà xé với nước dùng thanh, hành lá và lá chanh.', 'Đang bán', '1'),
        ('3', 'Bún bò Huế', 'Tô', '60000.00', 'dishes/bun-bo-hue.webp', 'Bún sợi to, thịt bò và nước dùng thơm sả theo vị miền Trung.', 'Đang bán', '1'),
        ('4', 'Bún riêu cua', 'Tô', '50000.00', 'dishes/bun-rieu-cua.webp', 'Bún riêu cua đồng với cà chua, đậu phụ và rau sống.', 'Đang bán', '1'),
        ('5', 'Bún chả Hà Nội', 'Suất', '60000.00', 'dishes/bun-cha-ha-noi.webp', 'Bún tươi, chả thịt nướng, nước chấm chua ngọt và rau sống.', 'Đang bán', '1'),
        ('6', 'Cơm tấm sườn', 'Đĩa', '65000.00', 'dishes/com-tam-suon.webp', 'Cơm tấm với sườn nướng, dưa leo và nước mắm pha.', 'Đang bán', '2'),
        ('7', 'Cơm gà Hội An', 'Đĩa', '65000.00', 'dishes/com-ga-hoi-an.webp', 'Cơm vàng nấu nước luộc gà, gà xé, rau răm và hành tây.', 'Đang bán', '2'),
        ('8', 'Cơm rang hải sản', 'Đĩa', '75000.00', 'dishes/com-rang-hai-san.webp', 'Cơm rang tơi với tôm, mực, trứng và rau củ.', 'Hết món', '2'),
        ('9', 'Cơm chiên dương châu', 'Đĩa', '60000.00', 'dishes/com-chien-duong-chau.webp', 'Cơm chiên với trứng, rau củ, thịt và tôm theo kiểu Dương Châu.', 'Ngừng phục vụ', '2'),
        ('10', 'Cá kho tộ', 'Niêu', '95000.00', 'dishes/ca-kho-to.webp', 'Cá kho trong niêu với nước mắm, tiêu và nước màu.', 'Đang bán', '3'),
        ('11', 'Thịt kho trứng', 'Phần', '85000.00', 'dishes/thit-kho-trung.webp', 'Thịt ba chỉ kho mềm cùng trứng, nước dừa và nước mắm.', 'Đang bán', '3'),
        ('12', 'Bò lúc lắc', 'Đĩa', '145000.00', 'dishes/bo-luc-lac.webp', 'Thịt bò cắt khối xào lửa lớn với hành tây và rau ăn kèm.', 'Đang bán', '3'),
        ('13', 'Gà rang gừng', 'Đĩa', '110000.00', 'dishes/ga-rang-gung.webp', 'Gà rang săn với gừng thái sợi, nước mắm và hành lá.', 'Đang bán', '3'),
        ('14', 'Sườn xào chua ngọt', 'Đĩa', '105000.00', 'dishes/suon-xao-chua-ngot.webp', 'Sườn heo rim sốt chua ngọt, ăn cùng cơm trắng.', 'Hết món', '3'),
        ('15', 'Nem rán', 'Đĩa', '55000.00', 'dishes/nem-ran.webp', 'Nem cuốn nhân thịt, miến, mộc nhĩ, rán giòn và chấm nước mắm.', 'Đang bán', '4'),
        ('16', 'Gỏi cuốn tôm thịt', 'Phần', '45000.00', 'dishes/goi-cuon-tom-thit.webp', 'Bánh tráng cuốn tôm, thịt, bún và rau sống; một phần ba cuốn.', 'Đang bán', '4'),
        ('17', 'Nộm gà xé phay', 'Đĩa', '65000.00', 'dishes/nom-ga-xe-phay.webp', 'Gà xé trộn hành tây, rau răm và nước mắm chua ngọt.', 'Đang bán', '4'),
        ('18', 'Trà đào', 'Ly', '35000.00', 'dishes/tra-dao.webp', 'Trà ướp lạnh với đào ngâm và đá; vị ngọt nhẹ.', 'Hết món', '5'),
        ('19', 'Nước chanh', 'Ly', '25000.00', 'dishes/nuoc-chanh.webp', 'Chanh tươi pha đường và đá, điều chỉnh độ ngọt theo yêu cầu.', 'Đang bán', '5'),
        ('20', 'Cà phê sữa đá', 'Ly', '30000.00', 'dishes/ca-phe-sua-da.webp', 'Cà phê pha đậm, sữa đặc và đá theo phong cách Việt Nam.', 'Đang bán', '5');

    CREATE TEMPORARY TABLE seed_tblSupplier9 LIKE tblSupplier9;
    INSERT INTO seed_tblSupplier9 (id, name, address, phone, email, taxCode, description) VALUES
        ('1', 'Thực phẩm sạch Hòa Bình', '21 đường Thống Nhất, Hà Nội', '0906000001', 'ncc01@bepviet-demo.example', '0109000001', 'Nhà cung cấp giả lập cho bộ demo Bếp Việt Ba Miền; không phải thông tin giao dịch thực.'),
        ('2', 'Hải sản Biển Việt', '22 đường Thống Nhất, Hải Phòng', '0906000002', 'ncc02@bepviet-demo.example', '0109000002', 'Nhà cung cấp giả lập cho bộ demo Bếp Việt Ba Miền; không phải thông tin giao dịch thực.'),
        ('3', 'Nông sản Đà Lạt', '23 đường Thống Nhất, Lâm Đồng', '0906000003', 'ncc03@bepviet-demo.example', '0109000003', 'Nhà cung cấp giả lập cho bộ demo Bếp Việt Ba Miền; không phải thông tin giao dịch thực.'),
        ('4', 'Gạo và thực phẩm khô An Phú', '24 đường Thống Nhất, Nam Định', '0906000004', 'ncc04@bepviet-demo.example', '0109000004', 'Nhà cung cấp giả lập cho bộ demo Bếp Việt Ba Miền; không phải thông tin giao dịch thực.'),
        ('5', 'Gia vị truyền thống Phú Quốc', '25 đường Thống Nhất, Kiên Giang', '0906000005', 'ncc05@bepviet-demo.example', '0109000005', 'Nhà cung cấp giả lập cho bộ demo Bếp Việt Ba Miền; không phải thông tin giao dịch thực.'),
        ('6', 'Bách hóa và đồ uống Tây Nguyên', '26 đường Thống Nhất, Đắk Lắk', '0906000006', 'ncc06@bepviet-demo.example', '0109000006', 'Nhà cung cấp giả lập cho bộ demo Bếp Việt Ba Miền; không phải thông tin giao dịch thực.');

    CREATE TEMPORARY TABLE seed_tblMaterial9 LIKE tblMaterial9;
    INSERT INTO seed_tblMaterial9 (id, name, unit, referencePrice) VALUES
        ('1', 'Thịt bò', 'kg', '240000.00'),
        ('2', 'Thịt heo ba chỉ', 'kg', '125000.00'),
        ('3', 'Sườn heo', 'kg', '145000.00'),
        ('4', 'Gà ta', 'kg', '115000.00'),
        ('5', 'Cá lóc', 'kg', '85000.00'),
        ('6', 'Tôm sú', 'kg', '180000.00'),
        ('7', 'Mực ống', 'kg', '165000.00'),
        ('8', 'Cua đồng', 'kg', '95000.00'),
        ('9', 'Rau cải', 'kg', '18000.00'),
        ('10', 'Cà chua', 'kg', '22000.00'),
        ('11', 'Hành tây', 'kg', '20000.00'),
        ('12', 'Gừng', 'kg', '40000.00'),
        ('13', 'Gạo tẻ', 'kg', '18000.00'),
        ('14', 'Bún tươi', 'kg', '16000.00'),
        ('15', 'Cà phê rang xay', 'hộp', '85000.00'),
        ('16', 'Nước mắm 500 ml', 'chai', '55000.00'),
        ('17', 'Dầu ăn', 'lít', '40000.00'),
        ('18', 'Nước trà đào đóng thùng', 'thùng', '240000.00');

    CREATE TEMPORARY TABLE seed_tblImportInvoice9 LIKE tblImportInvoice9;
    INSERT INTO seed_tblImportInvoice9 (id, importDate, note, supplierId, storekeeperId) VALUES
        ('1', '2026-01-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN001', '1', '9003'),
        ('2', '2026-01-08 08:15:00', 'Demo Bếp Việt Ba Miền 2026 - PN002', '2', '9004'),
        ('3', '2026-01-15 09:30:00', 'Demo Bếp Việt Ba Miền 2026 - PN003', '3', '2'),
        ('4', '2026-01-22 10:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN004', '4', '9003'),
        ('5', '2026-01-31 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN005', '5', '9004'),
        ('6', '2026-02-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN006', '1', '2'),
        ('7', '2026-02-05 08:15:00', 'Demo Bếp Việt Ba Miền 2026 - PN007', '2', '9003'),
        ('8', '2026-02-12 09:30:00', 'Demo Bếp Việt Ba Miền 2026 - PN008', '3', '9004'),
        ('9', '2026-02-18 10:45:00', 'Demo Bếp Việt Ba Miền 2026 - PN009', '4', '2'),
        ('10', '2026-02-24 14:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN010', '5', '9003'),
        ('11', '2026-02-28 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN011', '6', '9004'),
        ('12', '2026-03-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN012', '1', '2'),
        ('13', '2026-03-07 08:15:00', 'Demo Bếp Việt Ba Miền 2026 - PN013', '2', '9003'),
        ('14', '2026-03-14 09:30:00', 'Demo Bếp Việt Ba Miền 2026 - PN014', '3', '9004'),
        ('15', '2026-03-21 11:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN015', '4', '2'),
        ('16', '2026-03-31 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN016', '6', '9003'),
        ('17', '2026-04-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN017', '1', '9004'),
        ('18', '2026-04-09 08:15:00', 'Demo Bếp Việt Ba Miền 2026 - PN018', '2', '2'),
        ('19', '2026-04-19 09:30:00', 'Demo Bếp Việt Ba Miền 2026 - PN019', '5', '9003'),
        ('20', '2026-04-30 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN020', '6', '9004'),
        ('21', '2026-05-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN021', '1', '2'),
        ('22', '2026-05-10 09:30:00', 'Demo Bếp Việt Ba Miền 2026 - PN022', '3', '9003'),
        ('23', '2026-05-20 11:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN023', '4', '9004'),
        ('24', '2026-05-31 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN024', '5', '2'),
        ('25', '2026-07-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN025', '1', '9003'),
        ('26', '2026-07-15 08:15:00', 'Demo Bếp Việt Ba Miền 2026 - PN026', '2', '9004'),
        ('27', '2026-07-31 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN027', '6', '2'),
        ('28', '2026-09-01 00:00:00', 'Demo Bếp Việt Ba Miền 2026 - PN028', '1', '9003'),
        ('29', '2026-09-15 09:30:00', 'Demo Bếp Việt Ba Miền 2026 - PN029', '3', '9004'),
        ('30', '2026-09-30 23:59:59', 'Demo Bếp Việt Ba Miền 2026 - PN030', '5', '2');

    CREATE TEMPORARY TABLE seed_tblImportInvoiceItem9 LIKE tblImportInvoiceItem9;
    INSERT INTO seed_tblImportInvoiceItem9 (id, quantity, importPrice, importInvoiceId, materialId) VALUES
        ('1', '15.125', '122000.00', '1', '2'),
        ('2', '20.250', '141000.00', '1', '3'),
        ('3', '25.375', '112000.00', '1', '4'),
        ('4', '10.000', '90000.00', '2', '5'),
        ('5', '2.500', '180000.00', '2', '6'),
        ('6', '3.000', '150000.00', '2', '7'),
        ('7', '30.000', '20000.00', '3', '9'),
        ('8', '24.000', '25000.00', '3', '10'),
        ('9', '15.000', '40000.00', '3', '12'),
        ('10', '12.500', '16000.00', '4', '14'),
        ('11', '10.250', '41000.00', '4', '17'),
        ('12', '22.125', '18000.00', '4', '13'),
        ('13', '19.000', '38000.00', '5', '12'),
        ('14', '10.000', '53000.00', '5', '16'),
        ('15', '12.500', '38000.00', '5', '17'),
        ('16', '26.125', '141000.00', '6', '3'),
        ('17', '31.250', '112000.00', '6', '4'),
        ('18', '12.375', '234000.00', '6', '1'),
        ('19', '9.250', '94000.00', '7', '8'),
        ('20', '14.375', '84000.00', '7', '5'),
        ('21', '19.500', '178000.00', '7', '6'),
        ('22', '16.375', '18000.00', '8', '9'),
        ('23', '21.500', '22000.00', '8', '10'),
        ('24', '26.000', '20000.00', '8', '11'),
        ('25', '23.500', '18000.00', '9', '13'),
        ('26', '28.000', '16000.00', '9', '14'),
        ('27', '8.000', '41000.00', '9', '17'),
        ('28', '7.250', '38000.00', '10', '17'),
        ('29', '11.125', '38000.00', '10', '12'),
        ('30', '14.000', '53000.00', '10', '16'),
        ('31', '13.000', '54000.00', '11', '16'),
        ('32', '15.000', '83000.00', '11', '15'),
        ('33', '5.000', '234000.00', '11', '18'),
        ('34', '20.250', '238000.00', '12', '1'),
        ('35', '25.375', '124000.00', '12', '2'),
        ('36', '30.500', '144000.00', '12', '3'),
        ('37', '27.375', '181000.00', '13', '6'),
        ('38', '8.500', '166000.00', '13', '7'),
        ('39', '13.000', '95000.00', '13', '8'),
        ('40', '10.500', '20000.00', '14', '11'),
        ('41', '15.000', '41000.00', '14', '12'),
        ('42', '20.125', '18000.00', '14', '9'),
        ('43', '17.000', '17000.00', '15', '13'),
        ('44', '22.125', '15000.00', '15', '14'),
        ('45', '6.000', '38000.00', '15', '17'),
        ('46', '3.000', '234000.00', '16', '18'),
        ('47', '17.000', '54000.00', '16', '16'),
        ('48', '6.000', '83000.00', '16', '15'),
        ('49', '31.250', '124000.00', '17', '2'),
        ('50', '12.375', '144000.00', '17', '3'),
        ('51', '17.500', '114000.00', '17', '4'),
        ('52', '14.375', '166000.00', '18', '7'),
        ('53', '19.500', '95000.00', '18', '8'),
        ('54', '24.000', '85000.00', '18', '5'),
        ('55', '8.250', '41000.00', '19', '17'),
        ('56', '26.000', '41000.00', '19', '12'),
        ('57', '15.000', '56000.00', '19', '16'),
        ('58', '14.000', '53000.00', '20', '16'),
        ('59', '16.000', '82000.00', '20', '15'),
        ('60', '4.000', '230000.00', '20', '18'),
        ('61', '11.125', '122000.00', '21', '2'),
        ('62', '16.250', '141000.00', '21', '3'),
        ('63', '21.375', '112000.00', '21', '4'),
        ('64', '18.250', '20000.00', '22', '11'),
        ('65', '23.375', '40000.00', '22', '12'),
        ('66', '28.500', '18000.00', '22', '9'),
        ('67', '12.500', '40000.00', '23', '17'),
        ('68', '30.500', '18000.00', '23', '13'),
        ('69', '11.000', '16000.00', '23', '14'),
        ('70', '13.000', '56000.00', '24', '16'),
        ('71', '6.000', '41000.00', '24', '17'),
        ('72', '18.125', '41000.00', '24', '12'),
        ('73', '15.000', '120000.00', '25', '2'),
        ('74', '20.125', '139000.00', '25', '3'),
        ('75', '22.125', '161000.00', '26', '7'),
        ('76', '27.250', '93000.00', '26', '8'),
        ('77', '9.000', '84000.00', '27', '15'),
        ('78', '5.000', '238000.00', '27', '18'),
        ('79', '12.375', '241000.00', '28', '1'),
        ('80', '17.500', '126000.00', '28', '2'),
        ('81', '19.500', '22000.00', '29', '10'),
        ('82', '24.000', '20000.00', '29', '11'),
        ('83', '18.000', '53000.00', '30', '16'),
        ('84', '12.000', '38000.00', '30', '17');

    IF EXISTS (
        SELECT a.id FROM tblMember9 a JOIN seed_tblMember9 s ON a.id=s.id OR a.username=s.username
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`username` <=> BINARY s.`username`) AND (BINARY a.`role` <=> BINARY s.`role`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblMember9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblStaff9 a JOIN seed_tblStaff9 s ON a.id=s.id OR a.staffCode=s.staffCode
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`staffCode` <=> BINARY s.`staffCode`) AND (BINARY a.`position` <=> BINARY s.`position`) AND (a.`salaryCoefficient` <=> s.`salaryCoefficient`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblStaff9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblCustomer9 a JOIN seed_tblCustomer9 s ON a.id=s.id OR a.customerCode=s.customerCode
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`customerCode` <=> BINARY s.`customerCode`) AND (BINARY a.`registerDate` <=> BINARY s.`registerDate`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblCustomer9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblDishCategory9 a JOIN seed_tblDishCategory9 s ON a.id=s.id
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`name` <=> BINARY s.`name`) AND (BINARY a.`description` <=> BINARY s.`description`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblDishCategory9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblDish9 a JOIN seed_tblDish9 s ON a.id=s.id
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`name` <=> BINARY s.`name`) AND (BINARY a.`unit` <=> BINARY s.`unit`) AND (a.`price` <=> s.`price`) AND (BINARY a.`image` <=> BINARY s.`image`) AND (BINARY a.`description` <=> BINARY s.`description`) AND (BINARY a.`status` <=> BINARY s.`status`) AND (a.`dishCategoryId` <=> s.`dishCategoryId`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblDish9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblSupplier9 a JOIN seed_tblSupplier9 s ON a.id=s.id
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`name` <=> BINARY s.`name`) AND (BINARY a.`address` <=> BINARY s.`address`) AND (BINARY a.`phone` <=> BINARY s.`phone`) AND (BINARY a.`email` <=> BINARY s.`email`) AND (BINARY a.`taxCode` <=> BINARY s.`taxCode`) AND (BINARY a.`description` <=> BINARY s.`description`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblSupplier9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblMaterial9 a JOIN seed_tblMaterial9 s ON a.id=s.id
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`name` <=> BINARY s.`name`) AND (BINARY a.`unit` <=> BINARY s.`unit`) AND (a.`referencePrice` <=> s.`referencePrice`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblMaterial9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblImportInvoice9 a JOIN seed_tblImportInvoice9 s ON a.id=s.id
        WHERE NOT ((a.`id` <=> s.`id`) AND (BINARY a.`importDate` <=> BINARY s.`importDate`) AND (BINARY a.`note` <=> BINARY s.`note`) AND (a.`supplierId` <=> s.`supplierId`) AND (a.`storekeeperId` <=> s.`storekeeperId`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblImportInvoice9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT a.id FROM tblImportInvoiceItem9 a JOIN seed_tblImportInvoiceItem9 s ON a.id=s.id
        WHERE NOT ((a.`id` <=> s.`id`) AND (a.`quantity` <=> s.`quantity`) AND (a.`importPrice` <=> s.`importPrice`) AND (a.`importInvoiceId` <=> s.`importInvoiceId`) AND (a.`materialId` <=> s.`materialId`))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo data conflict in tblImportInvoiceItem9; nothing changed';
    END IF;

    IF EXISTS (
        SELECT id FROM seed_tblImportInvoice9
        WHERE YEAR(importDate) <> 2026 OR importDate >= DATE_ADD(CURRENT_DATE(),INTERVAL 1 DAY)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Demo imports must be in 2026 and not in the future';
    END IF;

    -- Preserve existing accounts (including passwords) and all existing business rows.
    INSERT INTO tblMember9 (id, username, password, name, role)
        SELECT s.id, s.username, s.password, s.name, s.role FROM seed_tblMember9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblMember9 a WHERE a.id=s.id);
    INSERT INTO tblStaff9 (id, staffCode, position, salaryCoefficient)
        SELECT s.id, s.staffCode, s.position, s.salaryCoefficient FROM seed_tblStaff9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblStaff9 a WHERE a.id=s.id);
    INSERT INTO tblCustomer9 (id, customerCode, registerDate)
        SELECT s.id, s.customerCode, s.registerDate FROM seed_tblCustomer9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblCustomer9 a WHERE a.id=s.id);
    INSERT INTO tblDishCategory9 (id, name, description)
        SELECT s.id, s.name, s.description FROM seed_tblDishCategory9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblDishCategory9 a WHERE a.id=s.id);
    INSERT INTO tblDish9 (id, name, unit, price, image, description, status, dishCategoryId)
        SELECT s.id, s.name, s.unit, s.price, s.image, s.description, s.status, s.dishCategoryId FROM seed_tblDish9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblDish9 a WHERE a.id=s.id);
    INSERT INTO tblSupplier9 (id, name, address, phone, email, taxCode, description)
        SELECT s.id, s.name, s.address, s.phone, s.email, s.taxCode, s.description FROM seed_tblSupplier9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblSupplier9 a WHERE a.id=s.id);
    INSERT INTO tblMaterial9 (id, name, unit, referencePrice)
        SELECT s.id, s.name, s.unit, s.referencePrice FROM seed_tblMaterial9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblMaterial9 a WHERE a.id=s.id);
    INSERT INTO tblImportInvoice9 (id, importDate, note, supplierId, storekeeperId)
        SELECT s.id, s.importDate, s.note, s.supplierId, s.storekeeperId FROM seed_tblImportInvoice9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblImportInvoice9 a WHERE a.id=s.id);
    INSERT INTO tblImportInvoiceItem9 (id, quantity, importPrice, importInvoiceId, materialId)
        SELECT s.id, s.quantity, s.importPrice, s.importInvoiceId, s.materialId FROM seed_tblImportInvoiceItem9 s
        WHERE NOT EXISTS (SELECT 1 FROM tblImportInvoiceItem9 a WHERE a.id=s.id);

    IF apply_changes THEN COMMIT; ELSE ROLLBACK; END IF;
    DROP TEMPORARY TABLE IF EXISTS seed_tblMember9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblStaff9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblCustomer9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblDishCategory9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblDish9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblSupplier9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblMaterial9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblImportInvoice9;
    DROP TEMPORARY TABLE IF EXISTS seed_tblImportInvoiceItem9;
    DO RELEASE_LOCK('restman.demo.bep_viet_ba_mien9');
END$$
DELIMITER ;
CALL seed_bep_viet_ba_mien9(TRUE);
DROP PROCEDURE seed_bep_viet_ba_mien9;
