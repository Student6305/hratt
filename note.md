# HR Employee Attrition Analysis
## Methodology and Technical Notes

### 1. Project Objective

The objective of this project is to analyse employee attrition, identify workforce segments with relatively high turnover, and present the results through SQL analysis and interactive Power BI dashboards.

### 2. Dataset and Tools

- **Dataset:** IBM HR Analytics Employee Attrition.
- **Total records:** 1,470.
- **Original columns:** 35.
- **Database:** SQL Server.
- **SQL environment:** SQL Server Management Studio (SSMS).
- **Visualisation:** Microsoft Power BI Desktop.
- **Main database table:** `dbo.employees`.

The `attrition_flag` column was added for analytical purposes:

- `1` = Employee left.
- `0` = Employee stayed.

The original `Attrition` column was imported as a SQL Server `BIT` data type. Therefore, numerical comparisons (`1` and `0`) were used in the SQL queries.

### 3. Data Validation

The dataset was checked for:

- Total row count.
- Distinct employee numbers.
- Missing values (NULLs).
- Attrition class distribution.

Expected class distribution:

| Attrition status | Flag | Employees | Percentage |
|---|---:|---:|---:|
| Stayed | 0 | 1,233 | 83.88% |
| Left | 1 | 237 | 16.12% |
| **Total** | | **1,470** | **100%** |

### 4. SQL Analysis: Q1–Q12

The `queries.sql` file contains the following analytical queries:

| Query | Analysis | Purpose |
|---|---|---|
| Q1 | Load and flag preparation | Create and populate `attrition_flag`. |
| Q2 | Data validation | Check records, unique employees, NULL values and attrition distribution. |
| Q3 | KPI summary | Compare employees who left and stayed using key workforce metrics. |
| Q4 | Department analysis | Compare attrition rates across departments. |
| Q5 | Job role analysis | Identify job roles with higher attrition rates. |
| Q6 | Employee characteristics | Analyse attrition by overtime, marital status, business travel and gender. |
| Q7 | Tenure analysis | Group employees according to years at the company and compare attrition. |
| Q8 | Income analysis | Divide employees into income quartiles and compare attrition. |
| Q9 | Job satisfaction | Compare job satisfaction levels across departments. |
| Q10 | Work-life balance | Compare work-life balance levels across departments. |
| Q11 | Risk profiles | Identify combinations of overtime, tenure and income associated with higher attrition. |
| Q12 | Numerical comparison | Compare average numerical employee attributes between employees who left and stayed. |

### 5. Power BI Data Model

The Power BI report uses one main table: `employees`.

Since the analysis uses a single table, no relationships between tables are required.

Two additional calculated columns were created.

#### 5.1 TenureBand

Employees were grouped according to their years at the company:

| Band | Definition |
|---|---|
| 0–2 Years | 0 to 2 years |
| 3–5 Years | 3 to 5 years |
| 6–10 Years | 6 to 10 years |
| 11+ Years | 11 years or more |

**Reasoning:** These groups make it possible to distinguish early-tenure employees from those with intermediate and longer service. The first two years are particularly useful for examining early employee turnover.

#### 5.2 IncomeQuartile

Employees were divided into four groups according to their monthly income:

| Quartile | Meaning |
|---|---|
| 1 | Lowest income group |
| 2 | Lower-middle income group |
| 3 | Upper-middle income group |
| 4 | Highest income group |

**Reasoning:** Quartiles provide a relative comparison of employees across the income distribution without requiring arbitrary salary thresholds. This makes it easier to investigate whether attrition differs between lower-income and higher-income groups.

**Technical note:** The Power BI quartile column uses a rank-based calculation. When multiple employees have identical income values, the group sizes may differ slightly from SQL `NTILE(4)`, which distributes ordered rows into four groups.

### 6. DAX Measures

The following DAX measures were created in Power BI:

```dax
Total Employees =
COUNTROWS(employees)

Total Attritions =
SUM(employees[attrition_flag])

Retained Employees =
[Total Employees] - [Total Attritions]

Attrition Rate =
DIVIDE([Total Attritions], [Total Employees], 0)

Retention Rate =
DIVIDE([Retained Employees], [Total Employees], 0)

Average Monthly Income =
AVERAGE(employees[MonthlyIncome])

Average Years at Company =
AVERAGE(employees[YearsAtCompany])

Average Age =
AVERAGE(employees[Age])

Average Job Satisfaction =
AVERAGE(employees[JobSatisfaction])

Average Work-Life Balance =
AVERAGE(employees[WorkLifeBalance])
```

The attrition and retention measures were formatted as percentages. Employee count measures were formatted as whole numbers.

### 7. SQL and Power BI Cross-Validation

The main KPI results were compared between SQL Server and Power BI to confirm consistency.

| Metric | SQL result | Power BI result | Status |
|---|---:|---:|---|
| Total employees | 1,470 | 1,470 | Match |
| Total attritions | 237 | 237 | Match |
| Overall attrition rate | 16.12% | 16.1% | Match (rounding) |
| Retention rate | 83.88% | 83.9% | Match (rounding) |

The overall attrition rate was verified using the same numerator and denominator in both tools:

237 / 1,470 = 16.12%.

Department and overtime results can also be compared by applying equivalent filters in both SQL and Power BI.

### 8. Dashboard Structure

The Power BI report contains two main pages.

#### Page 1 – Executive Overview

- Total employees.
- Total attritions.
- Attrition rate.
- Retention rate.
- Attrition by department.
- Attrition by job role.
- Attrition by tenure band.
- Attrition by overtime.
- Department and gender slicers.

#### Page 2 – Detailed Analysis

- Attrition by job satisfaction.
- Attrition by work-life balance.
- Attrition by income quartile.
- Attrition by business travel.
- High-risk employee profile table.
- Department, gender and job-role slicers.

### 9. Interpretation and Limitations

Attrition rates indicate the proportion of employees who left within a particular group. A higher rate identifies an area that may deserve further investigation, but it does not independently establish the cause of employee turnover.

The dataset is a snapshot, and some employee segments may have relatively small headcounts. Therefore, results should be interpreted in context. The rank-based Power BI income quartile calculation may also produce slightly different group assignments from SQL `NTILE(4)` when income values are tied.

### 10. Project Deliverables

| File | Description |
|---|---|
| `queries.sql` | SQL preparation, validation and analytical queries. |
| `hr_attrition.pbix` | Power BI data model, measures and dashboards. |
| `Executive_Overview.png` | Export of the executive overview page. |
| `Detailed_Analysis.png` | Export of the detailed analysis page. |
| `Data_Model.png` | Screenshot of the Power BI data model. |
| `summary.md` | Executive summary, findings and recommendations. |
| `note.md` | Technical methodology, validation and implementation notes. |