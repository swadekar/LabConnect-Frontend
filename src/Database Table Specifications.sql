# Database Table Specifications

## 1. Customer Domain

### 1.1 Customers
Primary table storing all customer information
#### Columns
- `customer_id` (INT, PK)
  - Auto-incrementing primary key
  - Unique identifier for each customer
  - Non-nullable
- `first_name` (VARCHAR(50))
  - Customer's first name
  - Non-nullable
  - Trimmed of whitespace before storage
- `last_name` (VARCHAR(50))
  - Customer's last name
  - Non-nullable
  - Trimmed of whitespace before storage
- `email` (VARCHAR(255))
  - Primary contact email
  - Must be unique
  - Validated for email format
  - Non-nullable
- `phone` (VARCHAR(20))
  - Primary contact phone number
  - Stored in E.164 format
  - Nullable
- `status` (ENUM)
  - Values: 'ACTIVE', 'INACTIVE', 'SUSPENDED'
  - Default: 'ACTIVE'
  - Non-nullable
- `create_date` (TIMESTAMP)
  - Account creation timestamp
  - Default: CURRENT_TIMESTAMP
  - Non-nullable
- `last_modified` (TIMESTAMP)
  - Last modification timestamp
  - Updated automatically
  - Non-nullable

#### Indexes
- PRIMARY KEY (`customer_id`)
- UNIQUE INDEX `idx_customer_email` (`email`)
- INDEX `idx_customer_status` (`status`)
- INDEX `idx_customer_name` (`last_name`, `first_name`)

### 1.2 CustomerAddresses
Stores multiple addresses for each customer
#### Columns
- `address_id` (INT, PK)
  - Auto-incrementing primary key
  - Unique identifier for each address
- `customer_id` (INT, FK)
  - References Customers.customer_id
  - Non-nullable
- `address_type` (ENUM)
  - Values: 'BILLING', 'SHIPPING', 'BOTH'
  - Non-nullable
- `is_default` (BOOLEAN)
  - Indicates default address for the type
  - Default: FALSE
- `street_line1` (VARCHAR(100))
  - Primary street address
  - Non-nullable
- `street_line2` (VARCHAR(100))
  - Additional address information
  - Nullable
- `city` (VARCHAR(50))
  - City name
  - Non-nullable
- `state` (VARCHAR(50))
  - State/Province name
  - Non-nullable for applicable countries
- `postal_code` (VARCHAR(20))
  - Postal/ZIP code
  - Format validated by country
  - Non-nullable
- `country` (CHAR(2))
  - ISO 3166-1 alpha-2 country code
  - Non-nullable
- `created_at` (TIMESTAMP)
  - Creation timestamp
  - Default: CURRENT_TIMESTAMP
- `updated_at` (TIMESTAMP)
  - Last update timestamp
  - Updated automatically

#### Indexes
- PRIMARY KEY (`address_id`)
- INDEX `idx_customer_addresses` (`customer_id`)
- INDEX `idx_address_type` (`customer_id`, `address_type`, `is_default`)

## 2. Product Domain

### 2.1 ProductCategories
Manages hierarchical product categorization
#### Columns
- `category_id` (INT, PK)
  - Auto-incrementing primary key
- `parent_category_id` (INT, FK)
  - Self-referential foreign key
  - Nullable for top-level categories
- `name` (VARCHAR(100))
  - Category name
  - Non-nullable
- `slug` (VARCHAR(100))
  - URL-friendly category identifier
  - Unique, auto-generated from name
- `description` (TEXT)
  - Category description
  - Nullable
- `is_active` (BOOLEAN)
  - Category visibility status
  - Default: TRUE
- `display_order` (INT)
  - Controls category display sequence
  - Default: 0
- `meta_title` (VARCHAR(100))
  - SEO meta title
  - Nullable
- `meta_description` (VARCHAR(255))
  - SEO meta description
  - Nullable

#### Indexes
- PRIMARY KEY (`category_id`)
- UNIQUE INDEX `idx_category_slug` (`slug`)
- INDEX `idx_parent_category` (`parent_category_id`)
- INDEX `idx_category_status` (`is_active`, `display_order`)

### 2.2 Products
Central product information storage
#### Columns
- `product_id` (INT, PK)
  - Auto-incrementing primary key
- `category_id` (INT, FK)
  - References ProductCategories.category_id
  - Non-nullable
- `sku` (VARCHAR(50))
  - Stock Keeping Unit
  - Unique product identifier
  - Non-nullable
- `name` (VARCHAR(255))
  - Product name
  - Non-nullable
- `description` (TEXT)
  - Detailed product description
  - Nullable
- `price` (DECIMAL(10,2))
  - Base product price
  - Non-nullable
  - Must be >= 0
- `cost` (DECIMAL(10,2))
  - Product cost
  - Nullable
  - Must be >= 0
- `weight` (DECIMAL(8,2))
  - Product weight in grams
  - Nullable
- `dimensions` (JSON)
  - Product dimensions (length, width, height)
  - Nullable
- `is_active` (BOOLEAN)
  - Product availability status
  - Default: TRUE
- `stock_level` (INT)
  - Current inventory level
  - Default: 0
- `low_stock_threshold` (INT)
  - Inventory alert threshold
  - Default: 10
- `created_at` (TIMESTAMP)
  - Product creation timestamp
  - Default: CURRENT_TIMESTAMP
- `updated_at` (TIMESTAMP)
  - Last update timestamp
  - Updated automatically

#### Indexes
- PRIMARY KEY (`product_id`)
- UNIQUE INDEX `idx_product_sku` (`sku`)
- INDEX `idx_product_category` (`category_id`)
- INDEX `idx_product_status` (`is_active`)
- INDEX `idx_product_stock` (`stock_level`)

## 3. Order Domain

### 3.1 Orders
Manages customer orders and transactions
#### Columns
- `order_id` (INT, PK)
  - Auto-incrementing primary key
- `customer_id` (INT, FK)
  - References Customers.customer_id
  - Non-nullable
- `order_number` (VARCHAR(50))
  - Human-readable order identifier
  - Unique, auto-generated
- `order_date` (TIMESTAMP)
  - Order placement timestamp
  - Default: CURRENT_TIMESTAMP
- `status` (ENUM)
  - Values: 'PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'
  - Default: 'PENDING'
- `subtotal` (DECIMAL(10,2))
  - Sum of all order items before tax/shipping
  - Non-nullable
- `tax_amount` (DECIMAL(10,2))
  - Total tax amount
  - Default: 0.00
- `shipping_amount` (DECIMAL(10,2))
  - Shipping cost
  - Default: 0.00
- `total_amount` (DECIMAL(10,2))
  - Final order total
  - Non-nullable
- `shipping_address_id` (INT, FK)
  - References CustomerAddresses.address_id
  - Non-nullable
- `billing_address_id` (INT, FK)
  - References CustomerAddresses.address_id
  - Non-nullable
- `payment_method` (VARCHAR(50))
  - Payment method identifier
  - Non-nullable
- `notes` (TEXT)
  - Order notes/comments
  - Nullable
- `created_at` (TIMESTAMP)
  - Order creation timestamp
  - Default: CURRENT_TIMESTAMP
- `updated_at` (TIMESTAMP)
  - Last update timestamp
  - Updated automatically

#### Indexes
- PRIMARY KEY (`order_id`)
- UNIQUE INDEX `idx_order_number` (`order_number`)
- INDEX `idx_order_customer` (`customer_id`)
- INDEX `idx_order_status` (`status`)
- INDEX `idx_order_dates` (`order_date`)

### 3.2 OrderItems
Details of individual items within orders
#### Columns
- `order_item_id` (INT, PK)
  - Auto-incrementing primary key
- `order_id` (INT, FK)
  - References Orders.order_id
  - Non-nullable
- `product_id` (INT, FK)
  - References Products.product_id
  - Non-nullable
- `quantity` (INT)
  - Number of units ordered
  - Must be > 0
  - Non-nullable
- `unit_price` (DECIMAL(10,2))
  - Price per unit at time of order
  - Non-nullable
- `subtotal` (DECIMAL(10,2))
  - Line item subtotal (quantity * unit_price)
  - Non-nullable
- `discount_amount` (DECIMAL(10,2))
  - Discount applied to line item
  - Default: 0.00
- `tax_amount` (DECIMAL(10,2))
  - Tax for line item
  - Default: 0.00
- `created_at` (TIMESTAMP)
  - Creation timestamp
  - Default: CURRENT_TIMESTAMP

#### Indexes
- PRIMARY KEY (`order_item_id`)
- INDEX `idx_orderitem_order` (`order_id`)
- INDEX `idx_orderitem_product` (`product_id`)

## 4. Inventory Domain

### 4.1 InventoryTransactions
Tracks all inventory movements
#### Columns
- `transaction_id` (INT, PK)
  - Auto-incrementing primary key
- `product_id` (INT, FK)
  - References Products.product_id
  - Non-nullable
- `transaction_type` (ENUM)
  - Values: 'PURCHASE', 'SALE', 'ADJUSTMENT', 'RETURN'
  - Non-nullable
- `quantity` (INT)
  - Quantity changed (positive or negative)
  - Non-nullable
- `reference_id` (VARCHAR(50))
  - External reference number
  - Nullable
- `notes` (TEXT)
  - Transaction notes
  - Nullable
- `transaction_date` (TIMESTAMP)
  - Transaction timestamp
  - Default: CURRENT_TIMESTAMP
- `created_by` (INT)
  - User ID who created transaction
  - Non-nullable

#### Indexes
- PRIMARY KEY (`transaction_id`)
- INDEX `idx_inventory_product` (`product_id`)
- INDEX `idx_inventory_type` (`transaction_type`)
- INDEX `idx_inventory_date` (`transaction_date`)

### 4.2 StockAlerts
Manages inventory alerts and notifications
#### Columns
- `alert_id` (INT, PK)
  - Auto-incrementing primary key
- `product_id` (INT, FK)
  - References Products.product_id
  - Non-nullable
- `alert_type` (ENUM)
  - Values: 'LOW_STOCK', 'OUT_OF_STOCK', 'OVERSTOCK'
  - Non-nullable
- `threshold` (INT)
  - Alert threshold quantity
  - Non-nullable
- `is_active` (BOOLEAN)
  - Alert status
  - Default: TRUE
- `last_triggered` (TIMESTAMP)
  - Last alert trigger timestamp
  - Nullable
- `created_at` (TIMESTAMP)
  - Alert creation timestamp
  - Default: CURRENT_TIMESTAMP

#### Indexes
- PRIMARY KEY (`alert_id`)
- INDEX `idx_alert_product` (`product_id`)
- INDEX `idx_alert_status` (`is_active`, `alert_type`)

## 5. Additional Considerations

### 5.1 Constraints
- All foreign keys should have ON DELETE RESTRICT
- Timestamps should use UTC timezone
- Monetary values should use DECIMAL(10,2) for consistency
- String fields should have appropriate length limits
- ENUMs should be used for fixed value sets

### 5.2 Audit Trail
Consider implementing triggers or audit tables for:
- Customer data changes
- Order status changes
- Price modifications
- Inventory adjustments
- Critical data modifications

### 5.3 Performance Optimization
- Regularly analyze and update statistics
- Monitor index usage
- Consider partitioning large tables
- Implement archiving strategy for historical data
- Use appropriate data types for space efficiency