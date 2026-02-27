# Point of Sale (POS) Database System
A fully functional Point of Sale database system built with Oracle SQL and PL/SQL, featuring a structured package of stored procedures, functions, triggers, views, and XML data export capabilities.

---

## Technologies Used
- Oracle Database 11g
- SQL / PL/SQL
- XML (Oracle XMLType)

---

## Database Schema

The system consists of the following tables:

| Table | Description |
|---|---|
| `CATEGORY` | Product categories |
| `EMPLOYEE` | Employee records |
| `BRANCH` | Store branch locations |
| `ITEMS` | Product inventory with pricing |
| `ITEMS_STOR_ENTRY` | Stock entry log |
| `CUSTOMER` | Customer records |
| `INVOICE` | Customer invoices |
| `INVOICEDETAIL` | Line items per invoice |
| `InvoiceDetail_deleted_History` | Audit trail for removed invoice items |

---

## Package: `pointOfSal`

All business logic is encapsulated in the `pointOfSal` PL/SQL package.

### Procedures
| Procedure | Description |
|---|---|
| `addCustomer(name, gender)` | Adds a new customer with duplicate validation |
| `addEmployee(name, job)` | Adds a new employee with duplicate validation |
| `addCategory(name)` | Adds a new product category |
| `addItem(name, price, quantity, category)` | Adds a new item linked to a category |
| `addBranch(name)` | Adds a new branch location |
| `addNewItemQuantity(name, qty)` | Updates stock and logs entry |
| `addInvoice(customer, employee, branch, date)` | Creates a new customer invoice |
| `addInvoiceDetail(invoiceNo, item, qty)` | Adds or updates an item on an invoice |
| `removeInvoiceItem(invoiceNo, item)` | Removes an item from an invoice and archives it |

### Supporting Functions
| Function | Description |
|---|---|
| `checkExisting*` | Validation functions for customer, employee, category, item, branch, invoice |
| `getItemNo / getCategoryNo` | Lookup functions returning IDs by name |
| `getItemPrice` | Returns item price by item number |
| `getNextInvoiceNo` | Auto-generates the next invoice number |
| `getItemInvoiceQuantity / getItemInvoicePaidPrice` | Retrieves invoice line item details |

---

## Triggers

| Trigger | Description |
|---|---|
| `trg_customer_no` | Auto-generates customer IDs on insert |
| `trg_employee_no` | Auto-generates employee IDs on insert |
| `trg_category_no` | Auto-generates category IDs on insert |
| `trg_generate_item_no` | Auto-generates item IDs on insert |
| `trg_generate_branch_no` | Auto-generates branch IDs on insert |
| `items_stor_entry_trigger` | Auto-generates stock entry IDs |
| `invoice_detail_trigger` | Auto-generates invoice detail IDs |
| `SECURE_INVOICE` | Blocks invoice inserts on Fridays and Saturdays |

---

## Views

- **`invoiceMaster`** — Displays full invoice summary including employee, customer, and branch names
- **`invoiceMasterDetail`** — Displays invoice line items with item names, quantities, prices, and totals

---

## XML Export

The system supports exporting invoice data to XML format stored in Oracle XMLType tables:
- `mTable` — Stores master invoice records as XML
- `detatilTable` — Stores invoice detail records as XML

---

## How to Run

1. Install Oracle Database 11g
2. Connect as a DBA user
3. Run the full `Project.sql` script in order:
   - Creates the `pointOfSal` user and grants privileges
   - Creates all tables
   - Creates the PL/SQL package
   - Creates triggers, views, and XML tables

```sql
-- Example usage
EXECUTE pointOfSal.addEmployee('John', 'Cashier');
EXECUTE pointOfSal.addCustomer('Ahmed', 'Male');
EXECUTE pointOfSal.addCategory('Electronics');
EXECUTE pointOfSal.addItem('Laptop', 2500, 10, 'Electronics');
EXECUTE pointOfSal.addInvoice('Ahmed', 'John', 'Medina Branch', SYSDATE);
EXECUTE pointOfSal.addInvoiceDetail(1, 'Laptop', 2);
```

---

## Key Features

- Full CRUD operations via a structured PL/SQL package
- Automatic ID generation using BEFORE INSERT triggers
- Data validation using cursors and exception handling
- Deletion audit trail via `InvoiceDetail_deleted_History`
- Security trigger preventing invoice creation on weekends
- XML data export for invoice master and detail records
