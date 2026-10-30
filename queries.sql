-- Q1: Load and Flag

-- Create attrition_flag only if it does not already exist
IF COL_LENGTH('dbo.employees', 'attrition_flag') IS NULL
BEGIN
    ALTER TABLE dbo.employees
    ADD attrition_flag INT;
END;

-- Populate attrition_flag
UPDATE dbo.employees
SET attrition_flag =
    CASE
        WHEN Attrition = 1 THEN 1
        WHEN Attrition = 0 THEN 0
    END;

-- Verify attrition_flag values
SELECT
    Attrition,
    attrition_flag,
    COUNT(*) AS EmployeeCount
FROM dbo.employees
GROUP BY Attrition, attrition_flag
ORDER BY attrition_flag;
-- =========================================
-- Q2: Data Validation
-- Business question: Is the employee dataset
-- complete, unique and correctly classified?
-- =========================================

-- 1. Total employee records
SELECT
    COUNT(*) AS TotalRows
FROM dbo.employees;

-- 2. Unique employee numbers
SELECT
    COUNT(DISTINCT EmployeeNumber) AS UniqueEmployees
FROM dbo.employees;

-- 3. NULL check for every column

DECLARE @sql NVARCHAR(MAX);

SELECT @sql = STRING_AGG(
    CAST(
        'SELECT ''' + REPLACE(name, '''', '''''') +
        ''' AS ColumnName, COUNT(*) AS NullCount
        FROM dbo.employees
        WHERE ' + QUOTENAME(name) + ' IS NULL'
        AS NVARCHAR(MAX)
    ),
    ' UNION ALL '
)
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.employees');

EXEC sp_executesql @sql;


-- 4. Attrition class balance

SELECT
    Attrition,
    attrition_flag,
    COUNT(*) AS EmployeeCount,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS Percentage
FROM dbo.employees
GROUP BY Attrition, attrition_flag
ORDER BY attrition_flag;

-- =========================================
-- Q3: KPI Summary
-- Business question: How do employees who
-- left differ from those who stayed?


SELECT
    CASE
        WHEN attrition_flag = 1 THEN 'Churned'
        ELSE 'Retained'
    END AS EmployeeStatus,

    COUNT(*) AS TotalEmployees,

    SUM(attrition_flag) AS TotalAttritions,

    ROUND(
        AVG(CAST(attrition_flag AS FLOAT)) * 100,
        2
    ) AS AttritionRate,

    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)), 2)
        AS AvgMonthlyIncome,

    ROUND(AVG(CAST(YearsAtCompany AS FLOAT)), 2)
        AS AvgYearsAtCompany,

    ROUND(AVG(CAST(JobSatisfaction AS FLOAT)), 2)
        AS AvgJobSatisfaction

FROM dbo.employees
GROUP BY attrition_flag
ORDER BY attrition_flag;
-- Q4: Which departments have the highest employee attrition rate?

SELECT
    Department,
    COUNT(*) AS TotalEmployees,
    SUM(attrition_flag) AS TotalAttritions,
    ROUND(
        SUM(attrition_flag) * 100.0 / COUNT(*),
        2
    ) AS AttritionRate
FROM dbo.employees
GROUP BY Department
ORDER BY AttritionRate DESC;
-- Q5: Attrition Rate by Job Role
-- Which job roles have the highest attrition rate?
-- Only include roles with at least 30 employees.

SELECT
    JobRole,
    COUNT(*) AS TotalEmployees,
    SUM(attrition_flag) AS TotalAttritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS AttritionRate
FROM dbo.employees
GROUP BY JobRole
HAVING COUNT(*) >= 30
ORDER BY AttritionRate DESC;


-- Q6: Attrition Rate by Employee Characteristics
-- How does attrition differ by overtime, marital status,
-- business travel and gender?

SELECT
    'OverTime' AS Category,
    CAST(OverTime AS VARCHAR(50)) AS GroupValue,
    COUNT(*) AS TotalEmployees,
    SUM(attrition_flag) AS TotalAttritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS AttritionRate
FROM dbo.employees
GROUP BY OverTime

UNION ALL

SELECT
    'MaritalStatus',
    CAST(MaritalStatus AS VARCHAR(50)),
    COUNT(*),
    SUM(attrition_flag),
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)
FROM dbo.employees
GROUP BY MaritalStatus

UNION ALL

SELECT
    'BusinessTravel',
    CAST(BusinessTravel AS VARCHAR(50)),
    COUNT(*),
    SUM(attrition_flag),
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)
FROM dbo.employees
GROUP BY BusinessTravel

UNION ALL

SELECT
    'Gender',
    CAST(Gender AS VARCHAR(50)),
    COUNT(*),
    SUM(attrition_flag),
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)
FROM dbo.employees
GROUP BY Gender

ORDER BY Category, AttritionRate DESC;

-- Q7: Attrition Rate by Tenure Band
-- Which tenure groups have the highest attrition?

SELECT
    CASE
        WHEN YearsAtCompany BETWEEN 0 AND 2 THEN '0-2 Years'
        WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 Years'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 Years'
        ELSE '11+ Years'
    END AS TenureBand,
    COUNT(*) AS TotalEmployees,
    SUM(attrition_flag) AS TotalAttritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS AttritionRate
FROM dbo.employees
GROUP BY
    CASE
        WHEN YearsAtCompany BETWEEN 0 AND 2 THEN '0-2 Years'
        WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 Years'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 Years'
        ELSE '11+ Years'
    END
ORDER BY MIN(YearsAtCompany);


-- Q8: Attrition Rate by Income Quartile
-- Does income level relate to employee attrition?

WITH IncomeGroups AS (
    SELECT
        attrition_flag,
        NTILE(4) OVER (ORDER BY MonthlyIncome) AS IncomeQuartile
    FROM dbo.employees
)
SELECT
    IncomeQuartile,
    COUNT(*) AS TotalEmployees,
    SUM(attrition_flag) AS TotalAttritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS AttritionRate
FROM IncomeGroups
GROUP BY IncomeQuartile
ORDER BY IncomeQuartile;


-- Q9: Department x Job Satisfaction
-- What is the attrition rate for each satisfaction level by department?

SELECT
    Department,
    ROUND(100.0 * SUM(CASE WHEN JobSatisfaction = 1 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN JobSatisfaction = 1 THEN 1 ELSE 0 END), 0), 2) AS Satisfaction_1,
    ROUND(100.0 * SUM(CASE WHEN JobSatisfaction = 2 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN JobSatisfaction = 2 THEN 1 ELSE 0 END), 0), 2) AS Satisfaction_2,
    ROUND(100.0 * SUM(CASE WHEN JobSatisfaction = 3 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN JobSatisfaction = 3 THEN 1 ELSE 0 END), 0), 2) AS Satisfaction_3,
    ROUND(100.0 * SUM(CASE WHEN JobSatisfaction = 4 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN JobSatisfaction = 4 THEN 1 ELSE 0 END), 0), 2) AS Satisfaction_4
FROM dbo.employees
GROUP BY Department
ORDER BY Department;


-- Q10: Department x Work-Life Balance
-- What is the attrition rate for each work-life balance level by department?

SELECT
    Department,
    ROUND(100.0 * SUM(CASE WHEN WorkLifeBalance = 1 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN WorkLifeBalance = 1 THEN 1 ELSE 0 END), 0), 2) AS Balance_1,
    ROUND(100.0 * SUM(CASE WHEN WorkLifeBalance = 2 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN WorkLifeBalance = 2 THEN 1 ELSE 0 END), 0), 2) AS Balance_2,
    ROUND(100.0 * SUM(CASE WHEN WorkLifeBalance = 3 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN WorkLifeBalance = 3 THEN 1 ELSE 0 END), 0), 2) AS Balance_3,
    ROUND(100.0 * SUM(CASE WHEN WorkLifeBalance = 4 THEN attrition_flag ELSE 0 END) /
        NULLIF(SUM(CASE WHEN WorkLifeBalance = 4 THEN 1 ELSE 0 END), 0), 2) AS Balance_4
FROM dbo.employees
GROUP BY Department
ORDER BY Department;

-- Q11: Multi-Factor Attrition Risk Profiles
-- Which combinations of overtime, tenure and income have the highest attrition?

WITH EmployeeProfiles AS (
    SELECT
        attrition_flag,
        OverTime,
        CASE
            WHEN YearsAtCompany BETWEEN 0 AND 2 THEN '0-2 Years'
            WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 Years'
            WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 Years'
            ELSE '11+ Years'
        END AS TenureBand,
        NTILE(4) OVER (ORDER BY MonthlyIncome) AS IncomeQuartile
    FROM dbo.employees
),
RiskProfiles AS (
    SELECT
        OverTime,
        TenureBand,
        IncomeQuartile,
        COUNT(*) AS TotalEmployees,
        SUM(attrition_flag) AS TotalAttritions,
        ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS AttritionRate
    FROM EmployeeProfiles
    GROUP BY OverTime, TenureBand, IncomeQuartile
    HAVING COUNT(*) >= 20
)
SELECT TOP 3 *
FROM RiskProfiles
ORDER BY AttritionRate DESC;


-- Q12: Numerical Attribute Comparison
-- How do average numerical employee characteristics differ
-- between employees who left and those who stayed?

SELECT
    CASE
        WHEN attrition_flag = 1 THEN 'Churned'
        ELSE 'Retained'
    END AS EmployeeStatus,
    COUNT(*) AS TotalEmployees,
    AVG(CAST(Age AS FLOAT)) AS AvgAge,
    AVG(CAST(DailyRate AS FLOAT)) AS AvgDailyRate,
    AVG(CAST(DistanceFromHome AS FLOAT)) AS AvgDistanceFromHome,
    AVG(CAST(Education AS FLOAT)) AS AvgEducation,
    AVG(CAST(EnvironmentSatisfaction AS FLOAT)) AS AvgEnvironmentSatisfaction,
    AVG(CAST(JobInvolvement AS FLOAT)) AS AvgJobInvolvement,
    AVG(CAST(JobLevel AS FLOAT)) AS AvgJobLevel,
    AVG(CAST(JobSatisfaction AS FLOAT)) AS AvgJobSatisfaction,
    AVG(CAST(MonthlyIncome AS FLOAT)) AS AvgMonthlyIncome,
    AVG(CAST(MonthlyRate AS FLOAT)) AS AvgMonthlyRate,
    AVG(CAST(NumCompaniesWorked AS FLOAT)) AS AvgCompaniesWorked,
    AVG(CAST(PercentSalaryHike AS FLOAT)) AS AvgSalaryHike,
    AVG(CAST(PerformanceRating AS FLOAT)) AS AvgPerformanceRating,
    AVG(CAST(RelationshipSatisfaction AS FLOAT)) AS AvgRelationshipSatisfaction,
    AVG(CAST(StockOptionLevel AS FLOAT)) AS AvgStockOptionLevel,
    AVG(CAST(TotalWorkingYears AS FLOAT)) AS AvgTotalWorkingYears,
    AVG(CAST(TrainingTimesLastYear AS FLOAT)) AS AvgTrainingTimesLastYear,
    AVG(CAST(WorkLifeBalance AS FLOAT)) AS AvgWorkLifeBalance,
    AVG(CAST(YearsAtCompany AS FLOAT)) AS AvgYearsAtCompany,
    AVG(CAST(YearsInCurrentRole AS FLOAT)) AS AvgYearsInCurrentRole,
    AVG(CAST(YearsSinceLastPromotion AS FLOAT)) AS AvgYearsSinceLastPromotion,
    AVG(CAST(YearsWithCurrManager AS FLOAT)) AS AvgYearsWithCurrManager
FROM dbo.employees
GROUP BY attrition_flag
ORDER BY attrition_flag;
