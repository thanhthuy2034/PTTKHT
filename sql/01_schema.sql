-- RestMan - schema of 19 physical tables from the approved ERD.
-- Do not create tables for SupplierStat9 / DishStat9 / MaterialStat9 / CustomerStat9.
-- Derived columns endTime, amount, totalAmount, totalDishAmount, totalPayment are not stored.
CREATE DATABASE IF NOT EXISTS restman CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE restman;

CREATE TABLE IF NOT EXISTS tblMember9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NULL,
    email VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    role VARCHAR(30) NOT NULL,
    note VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblCustomer9 (
    id INT PRIMARY KEY,
    customerCode VARCHAR(20) NOT NULL UNIQUE,
    registerDate DATE NOT NULL,
    CONSTRAINT fk_customer_member FOREIGN KEY (id) REFERENCES tblMember9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblStaff9 (
    id INT PRIMARY KEY,
    staffCode VARCHAR(20) NOT NULL UNIQUE,
    position VARCHAR(50) NULL,
    salaryCoefficient DECIMAL(5, 2) NULL,
    CONSTRAINT fk_staff_member FOREIGN KEY (id) REFERENCES tblMember9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblMembershipCard9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cardCode VARCHAR(30) NOT NULL UNIQUE,
    issueDate DATE NOT NULL,
    rewardPoints INT NOT NULL,
    cardRank VARCHAR(20) NULL,
    customerId INT NOT NULL UNIQUE,
    CONSTRAINT fk_card_customer FOREIGN KEY (customerId) REFERENCES tblCustomer9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblTableArea9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblTable9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    tableType VARCHAR(30) NULL,
    status VARCHAR(30) NULL,
    tableAreaId INT NOT NULL,
    CONSTRAINT fk_table_area FOREIGN KEY (tableAreaId) REFERENCES tblTableArea9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblReservationForm9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    guestCount INT NOT NULL,
    startTime DATETIME NOT NULL,
    createTime DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL,
    rejectReason VARCHAR(255) NULL,
    note VARCHAR(255) NULL,
    customerId INT NOT NULL,
    tableId INT NULL,
    CONSTRAINT fk_reservation_customer FOREIGN KEY (customerId) REFERENCES tblCustomer9(id),
    CONSTRAINT fk_reservation_table FOREIGN KEY (tableId) REFERENCES tblTable9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblDishCategory9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblDish9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    image VARCHAR(255) NULL,
    description VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL,
    dishCategoryId INT NOT NULL,
    CONSTRAINT fk_dish_category FOREIGN KEY (dishCategoryId) REFERENCES tblDishCategory9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblComboPackage9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    image VARCHAR(255) NULL,
    startDate DATE NULL,
    endDate DATE NULL,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblComboItem9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quantity INT NOT NULL,
    comboPackageId INT NOT NULL,
    dishId INT NOT NULL,
    CONSTRAINT fk_comboitem_package FOREIGN KEY (comboPackageId) REFERENCES tblComboPackage9(id),
    CONSTRAINT fk_comboitem_dish FOREIGN KEY (dishId) REFERENCES tblDish9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblOrderTicket9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    orderType VARCHAR(30) NOT NULL,
    createTime DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL,
    rejectReason VARCHAR(255) NULL,
    tableId INT NOT NULL,
    CONSTRAINT fk_order_table FOREIGN KEY (tableId) REFERENCES tblTable9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblOrderItem9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    note VARCHAR(255) NULL,
    orderTicketId INT NOT NULL,
    dishId INT NOT NULL,
    CONSTRAINT fk_orderitem_ticket FOREIGN KEY (orderTicketId) REFERENCES tblOrderTicket9(id),
    CONSTRAINT fk_orderitem_dish FOREIGN KEY (dishId) REFERENCES tblDish9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblOrderComboItem9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    note VARCHAR(255) NULL,
    orderTicketId INT NOT NULL,
    comboPackageId INT NOT NULL,
    CONSTRAINT fk_ordercombo_ticket FOREIGN KEY (orderTicketId) REFERENCES tblOrderTicket9(id),
    CONSTRAINT fk_ordercombo_package FOREIGN KEY (comboPackageId) REFERENCES tblComboPackage9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblBill9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paymentDate DATETIME NOT NULL,
    discountAmount DECIMAL(12, 2) NOT NULL,
    vatTax DECIMAL(12, 2) NOT NULL,
    paymentMethod VARCHAR(30) NOT NULL,
    customerId INT NULL,
    waitstaffId INT NOT NULL,
    orderTicketId INT NOT NULL UNIQUE,
    CONSTRAINT fk_bill_customer FOREIGN KEY (customerId) REFERENCES tblCustomer9(id),
    CONSTRAINT fk_bill_staff FOREIGN KEY (waitstaffId) REFERENCES tblStaff9(id),
    CONSTRAINT fk_bill_ticket FOREIGN KEY (orderTicketId) REFERENCES tblOrderTicket9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblSupplier9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    taxCode VARCHAR(30) NULL,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblMaterial9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    referencePrice DECIMAL(12, 2) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblImportInvoice9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    importDate DATETIME NOT NULL,
    note VARCHAR(255) NULL,
    supplierId INT NOT NULL,
    storekeeperId INT NOT NULL,
    CONSTRAINT fk_invoice_supplier FOREIGN KEY (supplierId) REFERENCES tblSupplier9(id),
    CONSTRAINT fk_invoice_staff FOREIGN KEY (storekeeperId) REFERENCES tblStaff9(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblImportInvoiceItem9 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quantity DECIMAL(12, 3) NOT NULL,
    importPrice DECIMAL(12, 2) NOT NULL,
    importInvoiceId INT NOT NULL,
    materialId INT NOT NULL,
    CONSTRAINT fk_item_invoice FOREIGN KEY (importInvoiceId) REFERENCES tblImportInvoice9(id),
    CONSTRAINT fk_item_material FOREIGN KEY (materialId) REFERENCES tblMaterial9(id)
) ENGINE=InnoDB;
