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

## Key Insights
- Delivery delays are strongly associated with lower review scores
- Certain high-revenue categories show lower customer satisfaction
- Payment method usage varies across order values
- Regional differences exist in delivery efficiency and customer ratings

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

## Interactive Dashboards
👉 [View Dashboard on Tableau Public](https://public.tableau.com/app/profile/joohyung.oh/viz/olist-sql/Dashboard2)


<img width="1854" height="760" alt="image" src="https://github.com/user-attachments/assets/3b8fb6b8-b496-48f9-ab9b-d2c5e40446d2" />

