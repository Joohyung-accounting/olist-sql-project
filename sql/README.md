Olist E-commerce SQL Analytics
What Drives Customer Satisfaction?
📌 Introduction

This project analyzes the Olist Brazilian e-commerce dataset using SQL to identify the key factors that influence customer satisfaction.

Rather than focusing only on sales metrics, this analysis explores how operational aspects such as delivery performance, product categories, payment methods, and geographic differences impact customer experience.

📊 Dataset Overview

The dataset is sourced from Olist, a Brazilian e-commerce platform, and stored in an SQLite database.

Data sources:

Brazilian E-commerce Dataset (Kaggle)
Olist Marketing Funnel Dataset (Kaggle)

Key tables used:

orders – order-level information
order_items – product-level details within each order
order_reviews – customer satisfaction scores
order_payments – payment type and value
products – product metadata
customers – customer location data
🎯 Business Questions
Main Question

What are the key drivers of customer satisfaction in Olist’s e-commerce platform?

Sub Questions
Does delivery delay affect review scores?
Which product categories have high sales but low satisfaction?
How do payment methods relate to purchasing behavior?
Are there geographic differences in delivery performance and satisfaction?
🧹 Data Cleaning & Assumptions
Only delivered orders are considered for satisfaction analysis
Delivery delay is defined as:
delivery_delay = delivered_date - estimated_delivery_date
Missing timestamps were excluded where necessary
Revenue is calculated using payment values
🔍 SQL Analysis
1. Overall Orders & Revenue Trends

We first examine overall business performance over time.

Monthly order volume
Monthly revenue trends
2. Delivery Performance

We analyze delivery efficiency using:

Delivery delay (in days)
On-time vs delayed delivery distribution
3. Delivery vs Customer Satisfaction ⭐

This is the core analysis of the project.

We compare average delivery delay across review scores to determine whether slower delivery leads to lower customer satisfaction.

4. Product Category Performance

We analyze:

Total orders by category
Average review score by category

Goal:

Identify categories with high sales but poor customer satisfaction
5. Payment Behavior

We examine:

Distribution of payment types
Average payment value by method
6. Geographic Analysis

We analyze differences across regions:

Average delivery delay by state
Average review score by state
📈 Key Findings
🔥 1. Delivery delay strongly impacts customer satisfaction

Orders delivered later than the estimated date tend to receive significantly lower review scores.

🔥 2. High sales do not guarantee high satisfaction

Some product categories generate large order volumes but have relatively low average review scores, indicating potential quality or expectation issues.

🔥 3. Payment behavior varies across customers

Credit card payments dominate and are associated with higher average transaction values.

🔥 4. Geographic disparities exist

Certain regions experience longer delivery times and lower customer satisfaction, suggesting logistics inefficiencies.

💡 Business Recommendations
Improve delivery logistics to reduce delays
Investigate low-rated product categories for quality issues
Optimize regional supply chain performance
Leverage high-value customer segments for targeted marketing
⚠️ Limitations
The dataset does not fully capture repeat customer behavior
Customer identifiers may not perfectly track long-term engagement
Analysis is based on correlation, not causation
🛠️ Tools Used
SQL (SQLite)
Python (optional for querying / notebook)
Jupyter Notebook (optional)
Git & GitHub
📌 Conclusion

This project demonstrates how SQL can be used not only for data querying, but also for extracting meaningful business insights.

The results highlight that operational efficiency—especially delivery performance—is a critical driver of customer satisfaction in e-commerce.

Future Work
Build a dashboard using Tableau or Power BI
Implement customer segmentation (RFM analysis)
Develop predictive models for customer satisfaction