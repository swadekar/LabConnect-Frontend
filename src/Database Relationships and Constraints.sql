# Database Relationships and Constraints

## 1. Primary Key Constraints

### 1.1 Natural vs Surrogate Keys
All major tables implement surrogate keys with the following specifications:
- Integer data type (INT)
- Auto-incrementing
- Named as `{table_name}_id`
- Non-nullable
- Clustered index

### 1.2 Composite Keys
Implemented in junction tables:
- `ProductCategories_Products`: (`product_id`, `category_id`)
- `OrderItems`: (`order_id`, `product_id`)
- Ensures unique combinations of related entities

## 2. Foreign Key Relationships

### 2.1 Customer Domain Relationships
1. Customers → CustomerAddresses (1:N)
   - Parent: `Customers.customer_id`
   - Child: `CustomerAddresses.customer_id`
   - ON DELETE: RESTRICT
   - ON UPDATE: CASCADE
   - Ensures customer existence before address creation

2. Customers → Orders (1:N)
   - Parent: `Customers.customer_id`
   - Child: `Orders.customer_id`
   - ON DELETE: RESTRICT
   - ON UPDATE: CASCADE
   - Maintains customer order history

### 2.2 Order Domain Relationships
1. Orders → OrderItems (1:N)
   - Parent: `Orders.order_id`
   - Child: `OrderItems.order_id`
   - ON DELETE: CASCADE
   - ON UPDATE: CASCADE
   - Ensures order items are removed with order

2. Orders → CustomerAddresses (N:1)
   - Parent: `CustomerAddresses.address_id`
   - Child: `Orders.shipping_address_id`
   - Child: `Orders.billing_address_id`
   - ON DELETE: RESTRICT
   - ON UPDATE: CASCADE
   - Maintains address integrity

### 2.3 Product Domain Relationships
1. ProductCategories → Products (1:N)
   - Parent: `ProductCategories.category_id`
   - Child: `Products.category_id`
   - ON DELETE: RESTRICT
   - ON UPDATE: CASCADE
   - Ensures category existence

2. ProductCategories → ProductCategories (1:N)
   - Self-referential relationship
   - Parent: `ProductCategories.category_id`
   - Child: `ProductCategories.parent_category_id`
   - ON DELETE: RESTRICT
   - ON UPDATE: CASCADE
   - Implements hierarchical categories

## 3. Data Integrity Constraints

### 3.1 Entity Integrity
1. Customer Data
   - Unique email addresses
   - Valid phone number formats
   - Complete name information

2. Product Data
   - Unique SKU values
   - Non-negative prices
   - Valid category assignment

3. Order Data
   - Valid status transitions
   - Matching total calculations
   - Complete address information

### 3.2 Referential Integrity
1. Order Processing
   - Valid customer reference
   - Existing product references
   - Valid address references

2. Inventory Management
   - Product existence checks
   - Stock level consistency
   - Transaction references

### 3.3 Domain Integrity
1. Status Fields
   ```sql
   Customer_Status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED')
   Order_Status ENUM('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED')
   Product_Status ENUM('ACTIVE', 'INACTIVE', 'DISCONTINUED')
   ```

2. Numeric Constraints
   ```sql
   CHECK (Product.price >= 0)
   CHECK (OrderItem.quantity > 0)
   CHECK (Product.stock_level >= 0)
   ```

## 4. Business Rules and Constraints

### 4.1 Customer Management
1. Address Rules
   - Maximum 5 addresses per customer
   - One default shipping address
   - One default billing address
   ```sql
   CREATE TRIGGER check_address_limit
   BEFORE INSERT ON CustomerAddresses
   FOR EACH ROW
   BEGIN
     IF (SELECT COUNT(*) FROM CustomerAddresses 
         WHERE customer_id = NEW.customer_id) >= 5 THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Maximum address limit reached';
     END IF;
   END;
   ```

### 4.2 Order Processing
1. Order Totals
   - Must match sum of items
   - Include tax and shipping
   ```sql
   CREATE TRIGGER validate_order_total
   BEFORE UPDATE ON Orders
   FOR EACH ROW
   BEGIN
     DECLARE calculated_total DECIMAL(10,2);
     SELECT SUM(subtotal) INTO calculated_total
     FROM OrderItems WHERE order_id = NEW.order_id;
     IF NEW.total_amount != (calculated_total + NEW.tax_amount + NEW.shipping_amount) THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Invalid order total';
     END IF;
   END;
   ```

2. Stock Validation
   - Check availability before order
   - Update inventory after order
   ```sql
   CREATE TRIGGER check_stock_level
   BEFORE INSERT ON OrderItems
   FOR EACH ROW
   BEGIN
     DECLARE available_stock INT;
     SELECT stock_level INTO available_stock
     FROM Products WHERE product_id = NEW.product_id;
     IF available_stock < NEW.quantity THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Insufficient stock';
     END IF;
   END;
   ```

### 4.3 Product Management
1. Price Rules
   - Sale price < Regular price
   - Cost < Sale price
   ```sql
   ALTER TABLE Products
   ADD CONSTRAINT check_prices
   CHECK (sale_price <= regular_price AND cost <= sale_price);
   ```

2. Category Rules
   - Maximum category depth: 3
   - Active products only in active categories

## 5. Performance Considerations

### 5.1 Index Strategy
1. Foreign Key Indexes
   - All FK columns indexed
   - Composite indexes for frequent joins

2. Search Optimization
   - Product name and description
   - Customer email and phone
   - Order number and status

### 5.2 Constraint Implementation
1. Declarative Constraints
   - Used for simple validations
   - Immediate checking

2. Trigger-based Constraints
   - Complex business rules
   - Cross-table validations

## 6. Maintenance Procedures

### 6.1 Constraint Validation
```sql
-- Regular constraint check
EXEC sp_validateconstraints
  @tablename = 'OrderItems',
  @constraintname = 'FK_OrderItems_Orders';
```

### 6.2 Relationship Maintenance
1. Regular cleanup of orphaned records
2. Validation of circular references
3. Monitoring of constraint violations
4. Performance impact assessment