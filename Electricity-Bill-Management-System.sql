-- Create the database schema for Electricity Bill Management System

-- Create Customers table to store customer details
CREATE TABLE Customers (
    customer_id NUMBER PRIMARY KEY,           -- customer_id as primary key
    customer_name VARCHAR2(255) NOT NULL,
    address VARCHAR2(4000),                    -- Oracle uses VARCHAR2 instead of TEXT
    phone_number VARCHAR2(20),
    email VARCHAR2(100),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sequence for customer_id
CREATE SEQUENCE customer_id_seq
START WITH 1
INCREMENT BY 1;

-- Create trigger to automatically populate customer_id using sequence
CREATE OR REPLACE TRIGGER trg_customer_id
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    SELECT customer_id_seq.NEXTVAL
    INTO :NEW.customer_id
    FROM dual;
END;
/

-- Create BillReadings table to store electricity consumption readings
CREATE TABLE BillReadings (
    reading_id NUMBER PRIMARY KEY,             -- reading_id as primary key
    customer_id NUMBER,
    reading_date DATE,
    previous_reading NUMBER,
    current_reading NUMBER,
    units_consumed NUMBER,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Create sequence for reading_id
CREATE SEQUENCE reading_id_seq
START WITH 1
INCREMENT BY 1;

-- Create trigger to automatically populate reading_id using sequence
CREATE OR REPLACE TRIGGER trg_reading_id
BEFORE INSERT ON BillReadings
FOR EACH ROW
BEGIN
    SELECT reading_id_seq.NEXTVAL
    INTO :NEW.reading_id
    FROM dual;
END;
/

-- Create Bills table to store bills generated based on consumption
CREATE TABLE Bills (
    bill_id NUMBER PRIMARY KEY,               -- bill_id as primary key
    customer_id NUMBER,
    bill_date DATE,
    amount NUMBER(10, 2),
    due_date DATE,
    status VARCHAR2(20) DEFAULT 'Unpaid',      -- Using VARCHAR2 instead of ENUM
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Create sequence for bill_id
CREATE SEQUENCE bill_id_seq
START WITH 1
INCREMENT BY 1;

-- Create trigger to automatically populate bill_id using sequence
CREATE OR REPLACE TRIGGER trg_bill_id
BEFORE INSERT ON Bills
FOR EACH ROW
BEGIN
    SELECT bill_id_seq.NEXTVAL
    INTO :NEW.bill_id
    FROM dual;
END;
/

-- Create Payments table to store payment information
CREATE TABLE Payments (
    payment_id NUMBER PRIMARY KEY,              -- payment_id as primary key
    bill_id NUMBER,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMBER(10, 2),
    payment_method VARCHAR2(50),
    FOREIGN KEY (bill_id) REFERENCES Bills(bill_id)
);

-- Create sequence for payment_id
CREATE SEQUENCE payment_id_seq
START WITH 1
INCREMENT BY 1;

-- Create trigger to automatically populate payment_id using sequence
CREATE OR REPLACE TRIGGER trg_payment_id
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    SELECT payment_id_seq.NEXTVAL
    INTO :NEW.payment_id
    FROM dual;
END;
/

-- Create BillImages table to store bill image paths and information
CREATE TABLE BillImages (
    image_id NUMBER PRIMARY KEY,               -- image_id as primary key
    bill_id NUMBER,
    image_path VARCHAR2(255),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES Bills(bill_id)
);

-- Create sequence for image_id
CREATE SEQUENCE image_id_seq
START WITH 1
INCREMENT BY 1;

-- Create trigger to automatically populate image_id using sequence
CREATE OR REPLACE TRIGGER trg_image_id
BEFORE INSERT ON BillImages
FOR EACH ROW
BEGIN
    SELECT image_id_seq.NEXTVAL
    INTO :NEW.image_id
    FROM dual;
END;
/

-- Create BillPayments table to track payment status against bills
CREATE TABLE BillPayments (
    bill_payment_id NUMBER PRIMARY KEY,          -- bill_payment_id as primary key
    bill_id NUMBER,
    payment_status VARCHAR2(20) DEFAULT 'Unpaid', -- Payment status
    FOREIGN KEY (bill_id) REFERENCES Bills(bill_id)
);

-- Create sequence for bill_payment_id
CREATE SEQUENCE bill_payment_id_seq
START WITH 1
INCREMENT BY 1;

-- Create trigger to automatically populate bill_payment_id using sequence
CREATE OR REPLACE TRIGGER trg_bill_payment_id
BEFORE INSERT ON BillPayments
FOR EACH ROW
BEGIN
    SELECT bill_payment_id_seq.NEXTVAL
    INTO :NEW.bill_payment_id
    FROM dual;
END;
/

-- Insert new customer
CREATE OR REPLACE PROCEDURE InsertCustomer(
    p_customer_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2
) IS
BEGIN
    INSERT INTO Customers (customer_name, address, phone_number, email)
    VALUES (p_customer_name, p_address, p_phone_number, p_email);
END;
/

-- Insert new bill reading (assuming readings are obtained from OCR)
CREATE OR REPLACE PROCEDURE InsertBillReading(
    p_customer_id IN NUMBER,
    p_reading_date IN DATE,
    p_previous_reading IN NUMBER,
    p_current_reading IN NUMBER
) IS
    v_units_consumed NUMBER;
BEGIN
    v_units_consumed := p_current_reading - p_previous_reading;

    INSERT INTO BillReadings (customer_id, reading_date, previous_reading, current_reading, units_consumed)
    VALUES (p_customer_id, p_reading_date, p_previous_reading, p_current_reading, v_units_consumed);
END;
/

-- Insert new bill based on consumption
CREATE OR REPLACE PROCEDURE InsertBill(
    p_customer_id IN NUMBER,
    p_bill_date IN DATE,
    p_amount IN NUMBER,
    p_due_date IN DATE
) IS
BEGIN
    INSERT INTO Bills (customer_id, bill_date, amount, due_date)
    VALUES (p_customer_id, p_bill_date, p_amount, p_due_date);
END;
/

-- Insert payment details
CREATE OR REPLACE PROCEDURE InsertPayment(
    p_bill_id IN NUMBER,
    p_amount IN NUMBER,
    p_payment_method IN VARCHAR2
) IS
BEGIN
    INSERT INTO Payments (bill_id, amount, payment_method)
    VALUES (p_bill_id, p_amount, p_payment_method);
    
    -- Update bill status to Paid
    UPDATE Bills
    SET status = 'Paid'
    WHERE bill_id = p_bill_id;
END;
/

-- Insert Bill Image (OCR generated path)
CREATE OR REPLACE PROCEDURE InsertBillImage(
    p_bill_id IN NUMBER,
    p_image_path IN VARCHAR2
) IS
BEGIN
    INSERT INTO BillImages (bill_id, image_path)
    VALUES (p_bill_id, p_image_path);
END;
/

BEGIN
    InsertCustomer('Rushi Ghotekar', 'At Post Sangamner', '123-456-7890', '@example.com');
END;
/

BEGIN
    InsertBillReading(1, TO_DATE('2025-01-07', 'YYYY-MM-DD'), 500, 600); -- Customer 1, previous 500, current 600
END;
/

BEGIN
    InsertBill(1, TO_DATE('2025-01-07', 'YYYY-MM-DD'), 100 * 0.10, TO_DATE('2025-02-07', 'YYYY-MM-DD'));
END;
/

BEGIN
    InsertPayment(1, 10.00, 'Credit Card');
END;
/

select *from Bills;
select *from Customers;
select *from Payments;
select *from BillImages;