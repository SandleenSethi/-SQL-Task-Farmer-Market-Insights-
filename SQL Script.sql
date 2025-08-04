use soulvibe_tech_internship;
-- Query1: Find the top 5 locations where the maximum number of farmers are associated with advisors.
WITH farmer_sim AS (
    SELECT *,
        CONCAT('A', LPAD(MOD(Farm_ID, 10), 3, '0')) AS Advisor_ID,
        CASE 
            WHEN MOD(Farm_ID, 5) = 0 THEN 'North'
            WHEN MOD(Farm_ID, 5) = 1 THEN 'South'
            WHEN MOD(Farm_ID, 5) = 2 THEN 'East'
            WHEN MOD(Farm_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM farmer_advisor_dataset
)
SELECT 
    District,COUNT(DISTINCT Farm_ID) AS Farmer_Count
FROM farmer_sim
GROUP BY District
ORDER BY Farmer_Count DESC
LIMIT 5;

-- Query2:. For each crop type, calculate the average market price and sort in descending order.
SELECT 
    Product AS Crop_Type,
    ROUND(AVG(Market_Price_per_ton), 2) AS Avg_Market_Price
FROM 
    market_researcher_dataset
GROUP BY 
    Product
ORDER BY 
    Avg_Market_Price DESC;

-- Query3: Count how many unique crops each farmer is associated with.
SELECT 
    Farm_ID, 
    COUNT(DISTINCT Crop_Type) AS Unique_Crop_Count
FROM farmer_advisor_dataset
GROUP BY Farm_ID;

-- Query4:Find farmers who are growing more than 3 different types of crops. 
SELECT 
    Farm_ID
FROM 
   farmer_advisor_dataset 
GROUP BY 
    Farm_ID
HAVING 
    COUNT(DISTINCT Crop_Type) > 3;
    
-- Query5: List all crops where the max and min market prices (from MarketResearcher) differ by more than ₹10 per kg.
SELECT 
    Product AS Crop_Type,
    MAX(Market_Price_per_ton) AS Max_Price,
    MIN(Market_Price_per_ton) AS Min_Price,
    (MAX(Market_Price_per_ton) - MIN(Market_Price_per_ton)) AS Price_Difference
FROM market_researcher_dataset
GROUP BY Product
HAVING Price_Difference > 10;

-- Query6: . Show all advisors who guide farmers growing the same crop in different districts.
WITH farmer_sim AS (
    SELECT *,
        CONCAT('A', LPAD(MOD(Farm_ID, 10), 3, '0')) AS Advisor_ID,
        CASE 
            WHEN MOD(Farm_ID, 5) = 0 THEN 'North'
            WHEN MOD(Farm_ID, 5) = 1 THEN 'South'
            WHEN MOD(Farm_ID, 5) = 2 THEN 'East'
            WHEN MOD(Farm_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM farmer_advisor_dataset
),
advisor_crop_districts AS (
    SELECT DISTINCT Advisor_ID, Crop_Type, District
    FROM farmer_sim
),
advisor_crop_diverse_districts AS (
    SELECT Advisor_ID, Crop_Type, COUNT(DISTINCT District) AS District_Count
    FROM advisor_crop_districts
    GROUP BY Advisor_ID, Crop_Type
    HAVING COUNT(DISTINCT District) > 1
)
SELECT * 
FROM advisor_crop_diverse_districts;

-- Query7: Rank crops by profit per unit (assume: market price - average cost from FarmerAdvisor) using RANK().
WITH farmer_cost AS (
    SELECT 
        Crop_Type,
        AVG((Fertilizer_Usage_kg + Pesticide_Usage_kg) / NULLIF(Crop_Yield_ton, 0)) AS Avg_Cost_per_Unit
    FROM farmer_advisor_dataset
    GROUP BY Crop_Type
),
market_price AS (
    SELECT 
        Product AS Crop_Type,
        AVG(Market_Price_per_ton) AS Avg_Market_Price
    FROM market_researcher_dataset
    GROUP BY Product
),
crop_profit AS (
    SELECT 
        m.Crop_Type,
        ROUND(m.Avg_Market_Price - f.Avg_Cost_per_Unit, 2) AS Profit_Per_Unit
    FROM market_price m
    JOIN farmer_cost f ON m.Crop_Type = f.Crop_Type
),
ranked_profit AS (
    SELECT *,
           RANK() OVER (ORDER BY Profit_Per_Unit DESC) AS Crop_Rank
    FROM crop_profit
)
SELECT * FROM ranked_profit;

-- Query8:Identify locations where the current market price of a crop is more than 20% above the average price of that crop across all locations.
WITH AvgCropPrice AS (
    SELECT 
        Product AS Crop_Type,
        AVG(Market_Price_per_ton) AS Avg_Price
    FROM market_researcher_dataset
    GROUP BY Product
),
SimulatedMarket AS (
    SELECT *,
        CASE 
            WHEN MOD(Market_ID, 5) = 0 THEN 'North'
            WHEN MOD(Market_ID, 5) = 1 THEN 'South'
            WHEN MOD(Market_ID, 5) = 2 THEN 'East'
            WHEN MOD(Market_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM market_researcher_dataset
)
SELECT 
    m.Market_ID,
    m.Product as Crop_Type,
    m.Market_Price_per_ton,
    m.District,
    a.Avg_Price,
    ROUND(((m.Market_Price_per_ton - a.Avg_Price) / a.Avg_Price) * 100, 2) AS Percent_Above_Avg
FROM SimulatedMarket m
JOIN AvgCropPrice a ON m.Product = a.Crop_Type
WHERE m.Market_Price_per_ton > 1.2 * a.Avg_Price;

-- Query9: List farmers who have been assigned the same advisor for all their crops.
WITH farmer_sim AS (
    SELECT *,
        CONCAT('A', LPAD(MOD(Farm_ID, 10), 3, '0')) AS Advisor_ID
    FROM farmer_advisor_dataset
),
same_advisor_farmers AS (
    SELECT 
        Farm_ID,
        COUNT(DISTINCT Advisor_ID) AS Advisor_Count
    FROM 
        farmer_sim
    GROUP BY 
        Farm_ID
    HAVING 
        COUNT(DISTINCT Advisor_ID) = 1
)
-- Final Output
SELECT f.Farm_ID, MAX(f.Advisor_ID) AS Advisor_ID
FROM farmer_sim f
JOIN same_advisor_farmers s ON f.Farm_ID = s.Farm_ID
GROUP BY f.Farm_ID;

-- Query10: Create a CTE showing average profit per crop type by farmer and use it to list farmers making below-average profits on any crop.
-- Step 1: Average market price per crop (one row per crop)
WITH AvgMarketPrice AS (
    SELECT 
        Product AS Crop_Type,
        AVG(Market_Price_per_ton) AS Avg_Market_Price
    FROM 
        market_researcher_dataset
    GROUP BY 
        Product
),

-- Step 2: Farmer-level profit using average price per crop
FarmerProfits AS (
    SELECT 
        f.Farm_ID,
        f.Crop_Type,
        ((f.Crop_Yield_ton * a.Avg_Market_Price) - 
        (f.Fertilizer_Usage_kg + f.Pesticide_Usage_kg)) AS Profit
    FROM 
        farmer_advisor_dataset f
    JOIN 
        AvgMarketPrice a ON f.Crop_Type = a.Crop_Type
),

-- Step 3: Average profit across all farmers per crop
AvgCropProfits AS (
    SELECT 
        Crop_Type,
        AVG(Profit) AS Avg_Crop_Profit
    FROM 
        FarmerProfits
    GROUP BY 
        Crop_Type
)

-- Step 4: Get farmers making below-average profits
SELECT 
    fp.Farm_ID,
    fp.Crop_Type,
    fp.Profit,
    acp.Avg_Crop_Profit
FROM 
    FarmerProfits fp
JOIN 
    AvgCropProfits acp ON fp.Crop_Type = acp.Crop_Type
WHERE 
    fp.Profit < acp.Avg_Crop_Profit;

-- Query11: (Assume MarketResearcher has a PriceDate) — Use a window function to find the price change of each crop over the last 3 entries.
WITH market_with_date AS (
    SELECT 
        *,
        DATE_ADD('2024-01-01', INTERVAL MOD(Market_ID, 30) DAY) AS PriceDate
    FROM 
        market_researcher_dataset
)
SELECT 
    Market_ID,
    Product AS Crop_Type,
    PriceDate,
    Market_Price_per_ton,
    LAG(Market_Price_per_ton, 1) OVER (PARTITION BY Product ORDER BY PriceDate) AS Price_1_Day_Ago,
    LAG(Market_Price_per_ton, 2) OVER (PARTITION BY Product ORDER BY PriceDate) AS Price_2_Days_Ago,
    LAG(Market_Price_per_ton, 3) OVER (PARTITION BY Product ORDER BY PriceDate) AS Price_3_Days_Ago
FROM 
    market_with_date
ORDER BY 
    Product, PriceDate;

-- Query12:Create a new column that classifies crop growth rate as:- Low (<20%)- Medium (20–50%)- High (>50%)
-- Count the number of crops in each category.
SELECT 
  CASE 
    WHEN Crop_Yield_ton < 2 THEN 'Low'
    WHEN Crop_Yield_ton BETWEEN 2 AND 5 THEN 'Medium'
    ELSE 'High'
  END AS Yield_Category,
  COUNT(*) AS Num_Crops
FROM 
  farmer_advisor_dataset
GROUP BY 
  Yield_Category;
  
  -- Query13:Join the tables and display all farmers whose crop is sold in the same district at the highest price.
  -- Simulate Districts and get farmers whose crop sells at highest district price
WITH 
farmer_sim AS (
    SELECT *,
        CASE 
            WHEN MOD(Farm_ID, 5) = 0 THEN 'North'
            WHEN MOD(Farm_ID, 5) = 1 THEN 'South'
            WHEN MOD(Farm_ID, 5) = 2 THEN 'East'
            WHEN MOD(Farm_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM farmer_advisor_dataset
),
market_sim AS (
    SELECT *,
        CASE 
            WHEN MOD(Market_ID, 5) = 0 THEN 'North'
            WHEN MOD(Market_ID, 5) = 1 THEN 'South'
            WHEN MOD(Market_ID, 5) = 2 THEN 'East'
            WHEN MOD(Market_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM market_researcher_dataset
),
MaxPricePerCropDistrict AS (
    SELECT 
        District,
        Product AS Crop_Type,
        MAX(Market_Price_per_ton) AS Max_Price
    FROM market_sim
    GROUP BY District, Product
)
SELECT 
    f.Farm_ID,
    f.Crop_Type,
    f.District,
    m.Max_Price
FROM 
    farmer_sim f
JOIN 
    MaxPricePerCropDistrict m 
    ON f.Crop_Type = m.Crop_Type 
   AND f.District = m.District;

-- Query14:For each advisor, count how many of their farmers grow crops that fall under the “High” growth classification (from Q12).
-- Step 1: Simulate Advisor_ID and Growth Rate
WITH farmer_enriched AS (
    SELECT *,
        -- Simulate Advisor_ID (e.g., 10 advisors)
        CONCAT('A', MOD(Farm_ID, 10) + 1) AS Advisor_ID,
        
        -- Simulate Growth Rate (0–100%) just for demo
        MOD(Farm_ID * 7, 101) AS Growth_Rate
    FROM farmer_advisor_dataset
),

-- Step 2: Add Growth Classification
classified_farmers AS (
    SELECT *,
        CASE 
            WHEN Growth_Rate < 20 THEN 'Low'
            WHEN Growth_Rate BETWEEN 20 AND 50 THEN 'Medium'
            ELSE 'High'
        END AS Growth_Class
    FROM farmer_enriched
)

-- Step 3: Count farmers per advisor with High growth
SELECT 
    Advisor_ID,
    COUNT(*) AS High_Growth_Farmer_Count
FROM 
    classified_farmers
WHERE 
    Growth_Class = 'High'
GROUP BY 
    Advisor_ID
ORDER BY 
    High_Growth_Farmer_Count DESC;
    

-- Query15:. Identify if any farmer has duplicate crop entries.

WITH ranked_farmers AS (
  SELECT *, 
         ROW_NUMBER() OVER (PARTITION BY Farm_ID, Crop_Type ORDER BY Farm_ID) AS rn
  FROM farmer_advisor_dataset
)
SELECT * 
FROM ranked_farmers
WHERE rn = 1;

-- Query16:List all crops grown by farmers that are not listed in the MarketResearcher table.
SELECT DISTINCT f.Crop_Type
FROM farmer_advisor_dataset f
WHERE NOT EXISTS (
    SELECT 1
    FROM market_researcher_dataset m
    WHERE TRIM(LOWER(f.Crop_Type)) = TRIM(LOWER(m.Product))
);


-- Query17: For each crop, determine which location has the highest average profit margin.
WITH farmer_sim AS (
    SELECT *,
        CASE 
            WHEN MOD(Farm_ID, 5) = 0 THEN 'North'
            WHEN MOD(Farm_ID, 5) = 1 THEN 'South'
            WHEN MOD(Farm_ID, 5) = 2 THEN 'East'
            WHEN MOD(Farm_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM farmer_advisor_dataset
),
market_sim AS (
    SELECT *,
        CASE 
            WHEN MOD(Market_ID, 5) = 0 THEN 'North'
            WHEN MOD(Market_ID, 5) = 1 THEN 'South'
            WHEN MOD(Market_ID, 5) = 2 THEN 'East'
            WHEN MOD(Market_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM market_researcher_dataset
),
farmer_with_margin AS (
    SELECT 
        f.Crop_Type,
        f.District,
        ((f.Crop_Yield_ton * m.Market_Price_per_ton - f.Fertilizer_Usage_kg - f.Pesticide_Usage_kg) / NULLIF((f.Crop_Yield_ton * m.Market_Price_per_ton), 0)) AS Profit_Margin
    FROM farmer_sim f
    JOIN market_sim m 
        ON f.Crop_Type = m.Product AND f.District = m.District
        Limit 1000
),
avg_margin_per_crop_district AS (
    SELECT 
        Crop_Type,
        District,
        ROUND(AVG(Profit_Margin), 4) AS Avg_Profit_Margin
    FROM farmer_with_margin
    GROUP BY Crop_Type, District
),
ranked_margins AS (
    SELECT *,
           RANK() OVER (PARTITION BY Crop_Type ORDER BY Avg_Profit_Margin DESC) AS rk
    FROM avg_margin_per_crop_district
)
SELECT Crop_Type, District, Avg_Profit_Margin
FROM ranked_margins
WHERE rk = 1;

-- Query18:Use window functions to find the second-highest market price crop per district.
WITH market_with_district AS (
    SELECT *,
        CASE 
            WHEN MOD(Market_ID, 5) = 0 THEN 'North'
            WHEN MOD(Market_ID, 5) = 1 THEN 'South'
            WHEN MOD(Market_ID, 5) = 2 THEN 'East'
            WHEN MOD(Market_ID, 5) = 3 THEN 'West'
            ELSE 'Central'
        END AS District
    FROM market_researcher_dataset
),
ranked_prices AS (
    SELECT 
        District,
        Product,
        Market_Price_per_ton,
        RANK() OVER (
            PARTITION BY District  
            ORDER BY Market_Price_per_ton DESC
        ) AS price_rank
    FROM market_with_district
)
SELECT 
    District,
    Product,
    Market_Price_per_ton
FROM ranked_prices
WHERE price_rank = 2;

-- Query19:List all advisors associated with more than 5 distinct crop types
SELECT 
    Advisor_ID,
    COUNT(DISTINCT Crop_Type) AS Distinct_Crops
FROM 
    farmer_sim
GROUP BY 
    Advisor_ID
HAVING 
    COUNT(DISTINCT Crop_Type) > 5;


-- QUery20:Find farmers who consistently grow the same crop type for all seasons (assume a Season column exists or mock one for the exercise).
WITH farmer_seasonal AS (
    SELECT *,
        CASE 
            WHEN MOD(Farm_ID, 3) = 0 THEN 'Spring'
            WHEN MOD(Farm_ID, 3) = 1 THEN 'Summer'
            ELSE 'Winter'
        END AS Season
    FROM farmer_advisor_dataset
),
consistent_crop_farmers AS (
    SELECT 
        Farm_ID,
        COUNT(DISTINCT Crop_Type) AS Crop_Count,
        MAX(Crop_Type) AS Consistent_Crop
    FROM farmer_seasonal
    GROUP BY Farm_ID
    HAVING COUNT(DISTINCT Crop_Type) = 1
)
SELECT Farm_ID, Consistent_Crop
FROM consistent_crop_farmers;
