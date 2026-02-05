# # Vehicle Sales Business Analysis

## Overview
This project presents an end-to-end business analysis of vehicle sales data, focusing on sales performance, demand trends, pricing effectiveness, and inventory optimization. The analysis was designed to replicate a real-world Business Analyst workflow, from data preparation in SQL to executive-level dashboards in Tableau Public.

The goal of this project is to demonstrate strong analytical reasoning, clean data modeling, and effective data storytelling for business stakeholders.

---

## Business Objectives
The analysis aims to answer the following key business questions:

1. Which year experienced the highest vehicle sales volume and strongest pricing performance?
2. Which vehicle makes and transmission types sell the most?
3. Which U.S. states generate the highest vehicle sales?
4. Which vehicles underperform and should be excluded from inventory?
5. When do vehicle sales peak by year, month, and day of the week?

---

## Tools & Technologies
- **SQL Server (SSMS)** — Data exploration, cleaning, and transformation using T-SQL  
- **Tableau Public** — Data visualization and dashboard development  
- **GitHub** — Version control and project documentation  

---

## Data Preparation (SQL)
Raw vehicle sales data was cleaned and transformed in SQL Server using T-SQL. Key preparation steps included:

- Standardizing vehicle makes and transmission values
- Cleaning and formatting sale dates
- Handling nulls and invalid records
- Creating analytical metrics such as:
  - Price vs. Market (selling price compared to MMR)
  - Sales volume by time and geography
- Producing a final analytics-ready view for visualization

All SQL logic is documented in the `/sql` folder.

Data source: https://www.kaggle.com/datasets/syedanwarafridi/vehicle-sales-data
---

## Analytics Dataset
A finalized analytics view was exported from SQL Server and used as the single source of truth for visualization:

This dataset was intentionally separated from raw data to reflect best practices in analytics and reporting.

---

## Visualizations (Tableau Public)
The cleaned dataset was visualized using Tableau Public to create interactive dashboards designed for executive and recruiter audiences.

### Key Dashboards:
- **Executive Overview** — High-level sales performance and trends
- **Make & Transmission Analysis** — Demand by vehicle type and transmission
- **Geographic Sales Analysis** — Vehicle sales by state
- **Inventory Optimization** — Identification of underperforming vehicles
- **Sales Timing Analysis** — Sales patterns by year, month, and day of week

Each dashboard focuses on clarity, usability, and business relevance.

---

## Key Insights
- Vehicle sales show strong seasonality by month and weekday
- Certain vehicle makes and transmission types consistently outperform others
- Geographic demand is concentrated in specific states
- Vehicles with low demand, high mileage, and below-market pricing represent inventory risk
- Time-based trends can inform staffing, pricing, and inventory decisions

---

## Repository Structure


---

## Tableau Public Link
🔗 https://public.tableau.com/app/profile/long.nguyen6677/viz/VehicleSalesBusinessAnalysis/Dashboard6

---

## Conclusion
This project demonstrates the complete Business Analyst workflow: translating business questions into data requirements, preparing clean analytical datasets using SQL, and communicating insights through clear and actionable dashboards. The analysis emphasizes decision support over raw reporting, aligning with real-world business analytics expectations.

---

## Author
Long Nguyen
Business Analyst | Data Analytics 
https://www.linkedin.com/in/long-nguyen-0b406616a/
