# SQL Internship Project – Farmer & Market Insights

##  Project Overview
This project is part of an internship at **Soulvibe.Tech**. The objective was to perform advanced SQL analysis on agricultural data to extract insights regarding farmer activities, crop advisory, and market performance.

Two main datasets were used:
- `farmer_advisor_dataset`
- `market_researcher_dataset`

We simulated additional fields like `Advisor_ID`, `District`, and `PriceDate` to enhance the realism of the queries.

---

##  Datasets Description

- **`farmer_advisor_dataset`**: Contains farm-level data such as `Farm_ID`, `Crop_Type`, `Fertilizer_Usage_kg`, `Pesticide_Usage_kg`, and `Crop_Yield_ton`.
- **`market_researcher_dataset`**: Contains market-level data including `Market_ID`, `Product` (crop), and `Market_Price_per_ton`.

---

##  Objectives

- Simulate additional features like `District`, `Advisor_ID`, and `Season`.
- Write optimized SQL queries to answer 20 data-driven business questions.
- Derive actionable insights to help support farmers and market researchers.
- Apply SQL window functions, CTEs, joins, grouping, and filtering.

---

##  SQL Tasks (20 Queries)

| Query # | Description |
|---------|-------------|
| Q1 | Top 5 districts with the highest number of farmers |
| Q2 | Average market price per crop (descending order) |
| Q3 | Unique crops grown per farmer |
| Q4 | Farmers growing more than 3 crops |
| Q5 | Crops with price difference > ₹10/kg |
| Q6 | Advisors guiding same crop in different districts |
| Q7 | Rank crops by profit per unit using `RANK()` |
| Q8 | Markets where crop price is 20% above average |
| Q9 | Farmers with the same advisor for all crops |
| Q10 | Farmers making below-average profits |
| Q11 | Track crop price change over last 3 entries (using `LAG()`) |
| Q12 | Classify crop growth rate: Low, Medium, High |
| Q13 | Farmers whose crops are sold at highest price in district |
| Q14 | Count of high-growth farmers under each advisor |
| Q15 | Detect duplicate crop entries per farmer |
| Q16 | Farmer-grown crops not listed in market data |
| Q17 | Most profitable district for each crop |
| Q18 | Second-highest crop price per district |
| Q19 | Advisors with more than 5 distinct crop types |
| Q20 | Farmers growing same crop across all seasons |

---

##  Tools Used

- **MySQL**: SQL query execution
- **MySQL Workbench / phpMyAdmin**: Query testing
- **Microsoft PowerPoint**: Visual presentation of query output
- **Microsoft Word**: Documentation/report
- **GitHub**: Version control and project hosting

---

##  Data Simulation & Cleaning

- **Simulated Columns**:
  - `Advisor_ID`: Based on modulo of `Farm_ID`
  - `District`: Based on modulo of `Farm_ID` and `Market_ID`
  - `Season`, `PriceDate`, `Growth_Rate`: Mock values created using `MOD()` and `DATE_ADD()`

- **Data Cleaning**:
  - Removed duplicates using `ROW_NUMBER()`
  - Trimmed inconsistent casing in crop names using `LOWER(TRIM())`
  - Handled divide-by-zero cases using `NULLIF()`

---

##  Key Insights

- Certain districts dominate in farmer participation.
- Some crops have highly volatile market prices.
- High profitability is correlated with specific regions.
- Advisor performance can be measured through crop diversity and growth rates.

---

##  Learning Outcomes

- Advanced use of SQL: CTEs, Window Functions, Ranking, Aggregation
- Real-world application of simulated datasets
- Translating data into meaningful visual insights
- End-to-end project workflow for SQL portfolio building

---

##  Files Included

- `SQL Script.sql` – All 20 SQL queries
- `SQL_Internship_Project_Report_Sandleen.docx` – Complete documentation
- `SQL_Internship_Presentation_Sandleen.pptx` – Slide presentation
- `SQL_Internship_Video.mp4` – Voice-over presentation 

---

##  Connect

For questions or collaborations, feel free to reach out via LinkedIn or GitHub.

---

> **Author:** Sandleen Sethi  
> **Internship:** Soulvibe.Tech – SQL Data Analytics  
> **Year:** 2025
