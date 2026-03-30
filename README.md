<div align="center">

# Olist E-commerce SQL Analytics  
### What Drives Customer Satisfaction?

</div>

---

## Overview

This project analyzes the Olist Brazilian e-commerce dataset using SQL to identify key drivers of customer satisfaction.

---

## Business Question

> **What drives customer satisfaction in an e-commerce platform?**

**Key Investigations**
- 🚚 Does delivery delay affect review scores?
- 📦 Which categories have high sales but low satisfaction?
- 💳 How do payment methods influence purchasing behavior?
- 🌎 Are there regional differences in delivery performance?

---

## Dataset

- Source: Olist Brazilian E-commerce Dataset (Kaggle)  
- Storage: SQLite  

**Core Tables**
- `orders`
- `order_items`
- `order_reviews`
- `order_payments`
- `products`
- `customers`

---

## Data Assumptions

- Only **delivered orders** are analyzed  
- Delivery delay defined as:

```sql
delivery_delay = delivered_date - estimated_delivery_date
```

## Tableau Dashboards
https://public.tableau.com/app/profile/joohyung.oh/viz/olist-sql/Dashboard2
