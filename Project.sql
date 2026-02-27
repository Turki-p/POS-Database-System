CREATE USER pointOfSal IDENTIFIED BY 1234;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW, CREATE PROCEDURE TO pointOfSal;
set SERVEROUTPUT ON;



-- step 3--
CREATE TABLE CATEGORY(
    CATNO INT PRIMARY KEY,
    CATOGERYNAME VARCHAR2(100)
);


CREATE TABLE EMPLOYEE(
    EMPLOYEENO INT PRIMARY KEY,
    EMPLOYEENAME VARCHAR2(100),
    JOB VARCHAR2(100)
);

CREATE TABLE BRANCH(
    BRANCHNO INT PRIMARY KEY,
    BRANCHNAME VARCHAR2(100)
);

CREATE TABLE ITEMS(
    ITEMNO INT PRIMARY KEY,
    ITEMNAME VARCHAR2(100),
    PRICE NUMBER(10, 2),
    TOTAL_QUANTITY INT,
    CATNO INT NOT NULL,
    CONSTRAINT FK_CATEGORY FOREIGN KEY (CATNO) REFERENCES CATEGORY(CATNO)
);

CREATE TABLE ITEMS_STOR_ENTRY(
    ENTRY_NO INT PRIMARY KEY,
    ITEMNO INT NOT NULL,
    ENTRY_DATE DATE DEFAULT SYSDATE NOT NULL,
    QUANTITY INT,
    EMPLOYEENO INT NOT NULL,
    CONSTRAINT FK_ITEM FOREIGN KEY (ITEMNO) REFERENCES ITEMS(ITEMNO),
    CONSTRAINT FK_EMPLOYEE FOREIGN KEY (EMPLOYEENO) REFERENCES EMPLOYEE(EMPLOYEENO)
);

CREATE TABLE CUSTOMER(
    CUSTOMERNO INT PRIMARY KEY,
    CUSTOMERNAME VARCHAR2(100),
    GENDER VARCHAR2(20)
);

CREATE TABLE INVOICE (
    INVOICENO INT PRIMARY KEY,
    EMPLOYEENO INT NOT NULL,
    CUSTOMERNO INT NOT NULL,
    TOTAL_PRICE NUMBER(10, 2) NOT NULL,
    INVOICEDATE DATE DEFAULT SYSDATE NOT NULL,
    BRANCHNO INT NOT NULL,
    CONSTRAINT FK_EMPLOYEE_INVOICE FOREIGN KEY (EMPLOYEENO) REFERENCES EMPLOYEE(EMPLOYEENO),
    CONSTRAINT FK_CUSTOMER FOREIGN KEY (CUSTOMERNO) REFERENCES CUSTOMER(CUSTOMERNO),
    CONSTRAINT FK_BRANCH FOREIGN KEY (BRANCHNO) REFERENCES BRANCH(BRANCHNO)
);

CREATE TABLE INVOICEDETAIL (
    INVOICEDETAILNO INT PRIMARY KEY,
    INVOICENO INT NOT NULL,
    ITEMNO INT NOT NULL,
    PAIDPRICE NUMBER(10, 2),
    QUANTITY INT,
    CONSTRAINT FK_INVOICE FOREIGN KEY (INVOICENO) REFERENCES INVOICE(INVOICENO),
    CONSTRAINT FK_ITEM_INVOICEDETAIL FOREIGN KEY (ITEMNO) REFERENCES ITEMS(ITEMNO)
);

CREATE TABLE InvoiceDetail_deleted_History (
    transaction_date DATE,
    invoiceNo INT,
    itemNo INT,
    quantity INT,
    paid_price NUMBER
);

alter table CATEGORY rename column CATOGERYNAME to CATEGORYNAME;



--step 4--

CREATE OR REPLACE PACKAGE pointOfSal AS
 -- A. Procedure to add a new customer
    PROCEDURE ADDCUSTOMER(CUSTOMERNAME IN VARCHAR2,GENDER IN VARCHAR2);
 -- B. Procedure to add a new employee
    PROCEDURE ADDEMPLOYEE(EMPLOYEENAME IN VARCHAR2,JOB IN VARCHAR2);
 -- C. Procedure to add a new category
    PROCEDURE ADDCATEGORY(CATEGORYNAME IN VARCHAR2);
 -- D. Procedure to add a new item
    PROCEDURE ADDITEM(
        ITEMNAME IN VARCHAR2,
        PRICE IN NUMBER,
        TOTAL_QUANTITY IN INT,
        CATEGORYNAME IN VARCHAR2
    );
 -- E. Procedure to add a new branch
    PROCEDURE ADDBRANCH(BRANCHNAME IN VARCHAR2);
 -- F. Procedure to add new item quantity
    PROCEDURE ADDNEWITEMQUANTITY(ITEMNAME IN VARCHAR2,NEWQUANTITY IN INT);
 -- G. Procedure to add a new customer invoice
    PROCEDURE ADDINVOICE(
        CUSTOMERNAME IN VARCHAR2,
        EMPLOYEENAME IN VARCHAR2,
        BRANCHNAME IN VARCHAR2,
        INVOICEDATE IN DATE
    );
 -- H. Procedure to add invoice detail
    PROCEDURE ADDINVOICEDETAIL(
        INVOICENO IN INT,
        ITEMNAME IN VARCHAR2,
        QUANTITY IN INT
    );
 -- I. Procedure to remove item from customer invoice
    PROCEDURE REMOVEINVOICEITEM(INVOICENO IN INT,ITEMNAME IN VARCHAR2);

    --supporting functions--

 -- Function to check if a customer exists
    FUNCTION CHECKEXISTINGCUSTOMER(CUSTOMERNAME IN VARCHAR2) RETURN BOOLEAN;
 -- Function to check if an employee exists
    FUNCTION CHECKEXISTINGEMPLOYEE(EMPLOYEENAME IN VARCHAR2) RETURN BOOLEAN;
 -- Function to check if a category exists
    FUNCTION CHECKEXISTINGCATEGORY(CATEGORYNAME IN VARCHAR2) RETURN BOOLEAN;
 -- Function to check if an item exists
    FUNCTION CHECKEXISTINGITEM(ITEMNAME IN VARCHAR2) RETURN BOOLEAN;
 -- Function to check if a branch exists
    FUNCTION CHECKEXISTINGBRANCH(BRANCHNAME IN VARCHAR2) RETURN BOOLEAN;
 -- Function to get category number by category name
    FUNCTION GETCATEGORYNO(CATEGORYNAME IN VARCHAR2) RETURN INT;
 -- Function to get item number by item name
    FUNCTION GETITEMNO(ITEMNAME IN VARCHAR2) RETURN INT;
 -- Function to get item price by item number
    FUNCTION GETITEMPRICE(ITEMNO IN INT) RETURN NUMBER;
 -- Function to get the next invoice number
    FUNCTION GETNEXTINVOICENO RETURN INT;
 -- Function to check if an invoice exists
    FUNCTION CHECKEXISTINGINVOICE(INVOICENO IN INT) RETURN BOOLEAN;
 -- Function to check if an item exists in an invoice
    FUNCTION CHECKEXISTINGINVOICEITEM(INVOICENO IN INT,ITEMNO IN INT) RETURN BOOLEAN;
 -- Function to get the quantity of an item in an invoice
    FUNCTION GETITEMINVOICEQUANTITY(INVOICENO IN INT,ITEMNO IN INT) RETURN INT;
 -- Function to get the paid price of an item in an invoice
    FUNCTION GETITEMINVOICEPAIDPRICE(INVOICENO IN INT,ITEMNO IN INT) RETURN NUMBER;
END pointOfSal;









--triggers--
CREATE OR REPLACE TRIGGER trg_customer_no
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(customerNo), 0) + 1 INTO :NEW.customerNo FROM customer;
END;
--
CREATE OR REPLACE TRIGGER trg_employee_no
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(EMPLOYEENO), 0) + 1 INTO :NEW.EMPLOYEENO FROM employee;
END;
--
CREATE OR REPLACE TRIGGER trg_category_no
BEFORE INSERT ON category
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(catNo), 0) + 1 INTO :NEW.catNo FROM category;
END;
--
CREATE OR REPLACE TRIGGER trg_generate_item_no
BEFORE INSERT ON items
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(itemNo), 0) + 1 INTO :NEW.itemNo FROM items;
END;
--
CREATE OR REPLACE TRIGGER trg_generate_branch_no
BEFORE INSERT ON branch
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(branchNo), 0) + 1 INTO :NEW.branchNo FROM branch;
END;

CREATE OR REPLACE TRIGGER items_stor_entry_trigger
BEFORE INSERT ON items_stor_entry
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(entry_no), 0) + 1
    INTO :NEW.entry_no
    FROM items_stor_entry;
END;

CREATE OR REPLACE TRIGGER invoice_detail_trigger
BEFORE INSERT ON INVOICEDETAIL
FOR EACH ROW
BEGIN
    SELECT NVL(MAX(INVOICEDETAILNO), 0) + 1
    INTO :NEW.INVOICEDETAILNO
    FROM INVOICEDETAIL;
END;

CREATE OR REPLACE TRIGGER SECURE_INVOICE BEFORE INSERT ON INVOICE BEGIN IF (
    TO_CHAR(SYSDATE, 'DY') IN ('FRI', 'SAT')
) THEN RAISE_APPLICATION_ERROR(
    -20500,
    'You may insert'
    ||' into INVOICE table only during '
    ||' business hours.'
);
END IF;
END;










--views--

CREATE VIEW invoiceMaster AS
SELECT 
    i.invoiceNo,
    i.invoiceDate,
    i.TOTAL_PRICE,
    (SELECT e.employeeName FROM employee e WHERE e.employeeNo = i.employeeNo) AS employeeName,
    (SELECT c.customerName FROM customer c WHERE c.customerNo = i.customerNo) AS customerName,
    (SELECT b.branchName FROM branch b WHERE b.branchNo = i.branchNo) AS branchName,
    i.customerNo,
    i.employeeNo,
    i.branchNo
FROM 
    invoice i;



CREATE VIEW invoiceMasterDetail AS
SELECT 
    id.invoiceNo,
    (SELECT it.itemName FROM items it WHERE it.itemNo = id.itemNo) AS itemName,
    id.quantity,
    id.paidPrice,
    (id.quantity * id.paidPrice) AS totalPrice,
    id.itemNo
FROM 
    invoiceDetail id;
















---package body ---

CREATE OR REPLACE PACKAGE BODY pointOfSal AS
    -- Function to check if a customer exists
    FUNCTION checkExistingCustomer(customerName IN VARCHAR2) RETURN BOOLEAN IS
    v_exists BOOLEAN := FALSE;
BEGIN
    -- Declare a cursor to fetch customer names
    FOR cust_rec IN (SELECT c.customerName FROM customer c) LOOP
        -- Check if the current customer name matches the input parameter
        IF cust_rec.customerName = customerName THEN
            v_exists := TRUE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_exists;
END checkExistingCustomer;
     




    -- Procedure to add a new customer
    PROCEDURE addCustomer(customerName IN VARCHAR2,gender IN VARCHAR2) IS
    BEGIN
        -- Validate if customer name already exists
        IF NOT checkExistingCustomer(customerName) THEN
            -- Insert new customer (customerNo will be generated by trigger)
            INSERT INTO customer (customerName, gender)
            VALUES (customerName, gender);
            DBMS_OUTPUT.PUT_LINE('Customer added successfully.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Customer already exists.');
        END IF;
    END addCustomer;
     

    -- Function to check if an employee exists
    FUNCTION checkExistingEmployee(employeeName IN VARCHAR2) RETURN BOOLEAN IS
    v_exists BOOLEAN := FALSE;
BEGIN
    -- Declare a cursor to fetch employee names
    FOR emp_rec IN (SELECT e.employeeName FROM employee e) LOOP
        -- Check if the current employee name matches the input parameter
        IF emp_rec.employeeName = employeeName THEN
            v_exists := TRUE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_exists;
END checkExistingEmployee;
     

    -- Procedure to add a new employee
    PROCEDURE addEmployee(employeeName IN VARCHAR2,job IN VARCHAR2) IS
    BEGIN
        -- Validate if employee name already exists
        IF NOT checkExistingEmployee(employeeName) THEN
            -- Insert new employee (employeeNo will be generated by trigger)
            INSERT INTO employee (employeeName, job)
            VALUES (employeeName, job);
            DBMS_OUTPUT.PUT_LINE('Employee added successfully.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Employee already exists.');
        END IF;
    END addEmployee;
     

        -- Function to check if a category exists
FUNCTION checkExistingCategory(categoryName IN VARCHAR2) RETURN BOOLEAN IS
    v_exists BOOLEAN := FALSE;
BEGIN
    -- Declare a cursor to fetch category names
    FOR cat_rec IN (SELECT ca.CATEGORYNAME FROM category ca) LOOP
        -- Check if the current category name matches the input parameter
        IF cat_rec.CATEGORYNAME = categoryName THEN
            v_exists := TRUE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_exists;
END checkExistingCategory;
    

    -- Procedure to add a new category
PROCEDURE addCategory(categoryName IN VARCHAR2) IS
    BEGIN
        -- Validate if category name already exists
        IF NOT checkExistingCategory(categoryName) THEN
            -- Insert new category (catNo will be generated by trigger)
            INSERT INTO category (categoryName)
            VALUES (categoryName);
            DBMS_OUTPUT.PUT_LINE('Category added successfully.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Category already exists.');
        END IF;
    END addCategory;

    -- Function to check if an item exists
FUNCTION checkExistingItem(itemName IN VARCHAR2) RETURN BOOLEAN IS
    v_exists BOOLEAN := FALSE;
BEGIN
    -- Declare a cursor to fetch item names
    FOR item_rec IN (SELECT ite.itemName FROM items ite) LOOP
        -- Check if the current item name matches the input parameter
        IF item_rec.itemName = itemName THEN
            v_exists := TRUE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_exists;
END checkExistingItem;

    -- Function to get category number
FUNCTION getCategoryNo(categoryName IN VARCHAR2) RETURN INT IS
    v_categoryNo INT := -1;
BEGIN
    -- Declare a cursor to fetch category numbers and names
    FOR cat_rec IN (SELECT ca.catNo, ca.categoryName FROM category ca) LOOP
        -- Check if the current category name matches the input parameter
        IF cat_rec.categoryName = categoryName THEN
            v_categoryNo := cat_rec.catNo;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_categoryNo;
END getCategoryNo;



    -- Procedure to add a new item
PROCEDURE addItem(itemName IN VARCHAR2,price IN NUMBER,total_quantity IN INT,categoryName IN VARCHAR2) IS
        v_categoryNo INT;
    BEGIN
        -- Validate if item name already exists
        IF checkExistingItem(itemName) THEN
            DBMS_OUTPUT.PUT_LINE('Item already exists.');
            RETURN;
        END IF;


        -- Get category number
        v_categoryNo := getCategoryNo(categoryName);
        
        -- Validate if category exists
        IF v_categoryNo = -1 THEN
            DBMS_OUTPUT.PUT_LINE('Category does not exist.');
            RETURN;
        END IF;

        -- Insert new item (itemNo will be generated by trigger)
        INSERT INTO items (itemName, price, total_quantity, CATNO)
        VALUES (itemName, price, total_quantity, v_categoryNo);
        
        DBMS_OUTPUT.PUT_LINE('One item record has been added.');
    END addItem;

        -- Function to check if a branch exists
FUNCTION checkExistingBranch(branchName IN VARCHAR2) RETURN BOOLEAN IS
    v_exists BOOLEAN := FALSE;
BEGIN
    -- Declare a cursor to fetch branch names
    FOR branch_rec IN (SELECT br.branchName FROM branch br) LOOP
        -- Check if the current branch name matches the input parameter
        IF branch_rec.branchName = branchName THEN
            v_exists := TRUE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_exists;
END checkExistingBranch;

    -- Procedure to add a new branch
PROCEDURE addBranch(branchName IN VARCHAR2) IS
BEGIN
    -- Validate if branch name already exists
    IF checkExistingBranch(branchName) THEN
        DBMS_OUTPUT.PUT_LINE('Branch already exists.');
        RETURN;
    END IF;

    -- Insert new branch (branchNo will be generated by trigger)
    INSERT INTO branch (branchName)
    VALUES (branchName);
    
    DBMS_OUTPUT.PUT_LINE('One branch record has been added.');
END addBranch;

FUNCTION getItemNo(itemName IN VARCHAR2) RETURN INT IS
    v_itemNo INT := -1;
BEGIN
    FOR ite_rec IN (SELECT ite.itemNo, ite.itemName FROM items ite) LOOP
        IF ite_rec.itemName = itemName THEN
            v_itemNo := ite_rec.itemNo;
            EXIT;
        END IF;
    END LOOP;

    RETURN v_itemNo;
END getItemNo;

PROCEDURE addNewItemQuantity(itemName IN VARCHAR2, newQuantity IN INT) IS
    v_itemNo INT;
    v_totalQuantity INT;
BEGIN
    -- Get the item number
    v_itemNo := getItemNo(itemName);

    -- Check if the item exists
    IF v_itemNo = -1 THEN
        DBMS_OUTPUT.PUT_LINE('No item has this name.');
        RETURN;
    END IF;

    -- Insert new entry into Items_stor_entry table
    INSERT INTO items_stor_entry (itemNo, entry_date, quantity, employeeNo)
    VALUES (v_itemNo, SYSDATE, newQuantity, 1); -- Assuming employeeNo is 1 for this example(employee number 1 will be the admin in our system always)

    -- Update the total quantity in the items table
    UPDATE items
    SET total_quantity = total_quantity + newQuantity
    WHERE items.itemNo = v_itemNo;

    -- Get the new total quantity
    SELECT ite.total_quantity INTO v_totalQuantity
    FROM items ite
    WHERE ite.itemNo = v_itemNo;

    -- Display the new total quantity
    DBMS_OUTPUT.PUT_LINE('Item: ' || itemName || ', New Total Quantity: ' || v_totalQuantity);
END addNewItemQuantity;

FUNCTION getNextInvoiceNo RETURN INT IS
    v_nextInvoiceNo INT;
BEGIN
    SELECT NVL(MAX(invoiceNo), 0) + 1 INTO v_nextInvoiceNo FROM invoice;
    RETURN v_nextInvoiceNo;
END getNextInvoiceNo;

PROCEDURE ADDINVOICE(
    CUSTOMERNAME IN VARCHAR2,
    EMPLOYEENAME IN VARCHAR2,
    BRANCHNAME IN VARCHAR2,
    INVOICEDATE IN DATE
) IS
    v_customer_no CUSTOMER.CUSTOMERNO%TYPE;
    v_employee_no EMPLOYEE.EMPLOYEENO%TYPE;
    v_branch_no BRANCH.BRANCHNO%TYPE;
    v_invoice_no INVOICE.INVOICENO%TYPE;
BEGIN
    -- Initialize variables to hold query results
    v_customer_no := -1;
    v_employee_no := -1;
    v_branch_no := -1;

    -- Check if the customer exists
    SELECT CUSTOMERNO INTO v_customer_no
    FROM CUSTOMER
    WHERE CUSTOMERNAME = ADDINVOICE.CUSTOMERNAME
    AND ROWNUM = 1;

    -- Check if the employee exists
    SELECT EMPLOYEENO INTO v_employee_no
    FROM EMPLOYEE
    WHERE EMPLOYEENAME = ADDINVOICE.EMPLOYEENAME
    AND ROWNUM = 1;

    -- Check if the branch exists
    SELECT BRANCHNO INTO v_branch_no
    FROM BRANCH
    WHERE BRANCHNAME = ADDINVOICE.BRANCHNAME
    AND ROWNUM = 1;

    -- If all entities exist, proceed to insert the invoice
    IF v_customer_no IS NOT NULL AND v_employee_no IS NOT NULL AND v_branch_no IS NOT NULL THEN
        -- Get the next invoice number
        v_invoice_no := GETNEXTINVOICENO;

        -- Insert the invoice
        INSERT INTO INVOICE (INVOICENO, EMPLOYEENO, CUSTOMERNO, TOTAL_PRICE, INVOICEDATE, BRANCHNO)
        VALUES (v_invoice_no, v_employee_no, v_customer_no, 0, INVOICEDATE, v_branch_no);

        DBMS_OUTPUT.PUT_LINE('One record has been created with invoice No: ' || v_invoice_no);
    ELSE
        -- Display appropriate error messages if entities don't exist
        IF v_customer_no IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Customer name doesn''t exist. Please re-enter correct name.');
        END IF;
        IF v_employee_no IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Employee name doesn''t exist. Please re-enter correct name.');
        END IF;
        IF v_branch_no IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Branch name doesn''t exist. Please re-enter correct name.');
        END IF;
    END IF;
END ADDINVOICE;

FUNCTION CHECKEXISTINGINVOICE(INVOICENO IN INT) RETURN BOOLEAN IS
    v_exists BOOLEAN := FALSE;
BEGIN
    -- Declare a cursor to fetch invoice numbers
    FOR inv_rec IN (SELECT inv.INVOICENO FROM invoice inv) LOOP
        -- Check if the current invoice number matches the input parameter
        IF inv_rec.INVOICENO = INVOICENO THEN
            v_exists := TRUE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_exists;
END CHECKEXISTINGINVOICE;


FUNCTION CHECKEXISTINGINVOICEITEM(
    INVOICENO IN INT,
    ITEMNO IN INT
) RETURN BOOLEAN IS
    v_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM INVOICEDETAIL
    WHERE INVOICENO = CHECKEXISTINGINVOICEITEM.INVOICENO
      AND ITEMNO = CHECKEXISTINGINVOICEITEM.ITEMNO;
    
    RETURN v_count > 0;
END CHECKEXISTINGINVOICEITEM;

 FUNCTION GETITEMPRICE(ITEMNO IN INT) RETURN NUMBER IS
    v_item_price items.price%TYPE := -1;
BEGIN
    -- Declare a cursor to fetch item numbers and prices
    FOR ite_rec IN (SELECT ite.ITEMNO, ite.PRICE FROM ITEMS ite) LOOP
        -- Check if the current item number matches the input parameter
        IF ite_rec.ITEMNO = ITEMNO THEN
            v_item_price := ite_rec.PRICE;
            EXIT; -- Exit loop early if a match is found
        END IF;
    END LOOP;

    RETURN v_item_price;
END GETITEMPRICE;


PROCEDURE ADDINVOICEDETAIL(
    INVOICENO IN INT,
    ITEMNAME IN VARCHAR2,
    QUANTITY IN INT
) IS
    v_item_no INT;
    v_item_price ITEMS.PRICE%TYPE;
BEGIN
    -- Check if the invoice exists
    IF CHECKEXISTINGINVOICE(INVOICENO) THEN
        -- Get the item number
        SELECT ITEMNO INTO v_item_no
        FROM ITEMS
        WHERE ITEMNAME = ADDINVOICEDETAIL.ITEMNAME
        AND ROWNUM = 1;

        -- If the item exists
        IF v_item_no IS NOT NULL THEN
            -- Get the item price
            SELECT PRICE INTO v_item_price
            FROM ITEMS
            WHERE ITEMNO = v_item_no
            AND ROWNUM = 1;
            
            -- Check if the item exists in the invoice
            IF NOT CHECKEXISTINGINVOICEITEM(INVOICENO, v_item_no) THEN
                -- Insert a new record into INVOICEDETAIL
                INSERT INTO INVOICEDETAIL (INVOICENO, ITEMNO, PAIDPRICE, QUANTITY)
                VALUES (INVOICENO, v_item_no, v_item_price, QUANTITY);
            ELSE
                -- Update the quantity in the existing record
                UPDATE INVOICEDETAIL
                SET QUANTITY = QUANTITY + ADDINVOICEDETAIL.QUANTITY
                WHERE INVOICENO = ADDINVOICEDETAIL.INVOICENO AND ITEMNO = v_item_no;
            END IF;
            
            -- Update the total price of the specific invoice
            UPDATE INVOICE
            SET TOTAL_PRICE = TOTAL_PRICE + (ADDINVOICEDETAIL.QUANTITY * v_item_price)
            WHERE INVOICENO = ADDINVOICEDETAIL.INVOICENO;
            
            -- Decrease the total quantity of the item in the ITEMS table
            UPDATE ITEMS
            SET TOTAL_QUANTITY = TOTAL_QUANTITY - ADDINVOICEDETAIL.QUANTITY
            WHERE ITEMNO = v_item_no;
            
            DBMS_OUTPUT.PUT_LINE('One item: ' || ITEMNAME || ' has been added successfully.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('There is no item with the name: ' || ITEMNAME);
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invoice with number ' || INVOICENO || ' does not exist.');
    END IF;
END ADDINVOICEDETAIL;

 FUNCTION getItemInvoicePaidPrice(invoiceNo IN INT, itemNo IN INT) RETURN NUMBER IS
    v_paidPrice NUMBER := -1;
BEGIN
    FOR inv_rec IN (SELECT inv.PAIDPRICE FROM InvoiceDetail inv WHERE inv.invoiceNo = invoiceNo AND inv.itemNo = itemNo) LOOP
        v_paidPrice := inv_rec.PAIDPRICE;
        EXIT;
    END LOOP;
    RETURN v_paidPrice;
END getItemInvoicePaidPrice;


FUNCTION getItemInvoiceQuantity(invoiceNo IN INT, itemNo IN INT) RETURN INT IS
    v_quantity INT := -1;
BEGIN
    FOR inv_rec IN (SELECT inv.quantity FROM InvoiceDetail inv WHERE inv.invoiceNo = invoiceNo AND inv.itemNo = itemNo) LOOP
        v_quantity := inv_rec.quantity;
        EXIT;
    END LOOP;

    RETURN v_quantity;
END getItemInvoiceQuantity;

PROCEDURE removeInvoiceItem(
    invoiceNo IN INT,
    itemName IN VARCHAR2
) IS
    v_itemNo INT;
    v_quantity INT;
    v_paidPrice NUMBER;
    v_exists BOOLEAN;
    v_itemPrice NUMBER;
BEGIN
    -- Get item number from item name
    v_itemNo := getItemNo(itemName);
    
    IF v_itemNo = -1 THEN
        DBMS_OUTPUT.PUT_LINE('No item has this name.');
        RETURN;
    END IF;

    -- Check if item exists in the invoice
    v_exists := checkExistingInvoiceItem(invoiceNo, v_itemNo);
    
    IF NOT v_exists THEN
        DBMS_OUTPUT.PUT_LINE('This item is not in the invoice.');
        RETURN;
    END IF;

    -- Get the quantity and paid price of the item in the invoice
    v_quantity := getItemInvoiceQuantity(invoiceNo, v_itemNo);
    v_paidPrice := getItemInvoicePaidPrice(invoiceNo, v_itemNo);

    -- Update the total quantity of the item in the items table
    UPDATE items
    SET total_quantity = total_quantity + v_quantity
    WHERE itemNo = v_itemNo;

    -- Get the current item price
    v_itemPrice := getItemPrice(v_itemNo);

    -- Decrease the total price of the specific invoice
    UPDATE invoice
    SET total_price = total_price - (v_quantity * v_paidPrice)
    WHERE invoiceNo = removeInvoiceItem.invoiceNo;

    -- Insert a record into InvoiceDetail_deleted_History
    INSERT INTO InvoiceDetail_deleted_History (invoiceNo, itemNo, quantity, paid_price, transaction_date)
    VALUES (invoiceNo, v_itemNo, v_quantity, v_paidPrice, SYSDATE);

    -- Delete the item from the InvoiceDetail table
    DELETE FROM InvoiceDetail
    WHERE invoiceNo = removeInvoiceItem.invoiceNo AND itemNo = v_itemNo;

    -- Output a success message
    DBMS_OUTPUT.PUT_LINE('One record deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END removeInvoiceItem;



    

END pointOfSal;



--xml--

Create table mTable(invoiceMaster XMLType);
Create table detatilTable(invoiceMasterDetail XMLType);


DECLARE
prXML CLOB;
BEGIN
FOR rec IN (SELECT * FROM invoiceMaster) LOOP
-- Construct Patient Record XML from the invoice data
prXML := '<Invoice>
<InvoiceNo>' || rec.invoiceNo || '</InvoiceNo>
<InvoiceDate>' || TO_CHAR(rec.invoiceDate, 'YYYY-MM-DD') || '</InvoiceDate>
<TotalPrice>' || rec.TOTAL_PRICE || '</TotalPrice>
<EmployeeName>' || rec.employeeName || '</EmployeeName>
<CustomerName>' || rec.customerName || '</CustomerName>
<BranchName>' || rec.branchName || '</BranchName>
<CustomerNo>' || rec.customerNo || '</CustomerNo>
<EmployeeNo>' || rec.employeeNo || '</EmployeeNo>
<BranchNo>' || rec.branchNo || '</BranchNo>
</Invoice>';
-- Insert this Invoice Record XML into the XMLType column
INSERT INTO mTable (invoiceMaster) VALUES (XMLTYPE(prXML));
END LOOP;
END;


DECLARE
imdXML CLOB;
BEGIN
FOR rec IN (SELECT * FROM invoiceMasterDetail) LOOP

imdXML:= '<Invoice>
<InvoiceNo>' || rec.invoiceNo || '</InvoiceNo>
<ITEMNAME>' || rec.ITEMNAME || '</ITEMNAME>
<QUANTITY>' || rec.QUANTITY || '</QUANTITY>
<PAIDPRICE>' || rec.PAIDPRICE || '</PAIDPRICE>
<TOTALPRICE>' || rec.TOTALPRICE || '</TOTALPRICE>
<ITEMNO>' || rec.ITEMNO || '</ITEMNO>
</Invoice>';
-- Insert this Invoice Record XML into the XMLType column
INSERT INTO detatilTable (invoiceMasterDetail) VALUES (XMLTYPE(imdXML));
END LOOP;
END;



