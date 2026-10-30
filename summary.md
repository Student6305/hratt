# HR Employee Attrition Analysis
## Executive Summary

### 1. Project Overview

This project analyses employee attrition using the IBM HR Analytics Employee Attrition dataset. The objective is to identify employee groups with higher turnover rates, examine potential factors associated with attrition, and present findings that can support HR decision-making.

SQL Server was used for data preparation, validation and analysis, while Microsoft Power BI was used to create calculated fields, key performance indicators and interactive dashboards.

The dataset contains **1,470 employee records** and **35 original columns**. An additional `attrition_flag` field was used, where 1 represents an employee who left and 0 represents an employee who stayed.

### 2. Key Performance Indicators

| KPI | Result |
|---|---:|
| Total employees | 1,470 |
| Employees who left | 237 |
| Employees retained | 1,233 |
| Overall attrition rate | 16.1% |
| Retention rate | 83.9% |

The overall attrition rate is calculated by dividing the number of employees who left by the total number of employees (237 / 1,470).

### 3. Six Key Findings

1. **Department differences:** Sales has the highest department attrition rate at approximately 21.5%, followed by Human Resources at 19.0% and Research & Development at 13.8%.

2. **Overtime:** Employees working overtime have a considerably higher attrition rate (approximately 30.5%) than employees who do not work overtime (approximately 10.4%).

3. **Job role:** Sales Representatives have a particularly high attrition rate of approximately 39.8%. Laboratory Technicians also show elevated attrition, at approximately 23.9%.

4. **Tenure:** Employees with shorter tenure are more likely to leave. The 0–2-year group has an attrition rate of approximately 36.1%, compared with approximately 7.5% among employees with 10 or more years at the company.

5. **Job satisfaction:** Employees reporting the lowest job satisfaction score (1) have an attrition rate of approximately 22.8%.

6. **Work-life balance:** Employees reporting the lowest work-life balance score (1) have an attrition rate of approximately 31.3%.

### 4. Five Business Recommendations

1. **Prioritise retention in Sales:** Review workload, management practices, compensation and career progression, particularly for Sales Representatives.

2. **Review overtime practices:** Monitor overtime frequency and duration, identify teams experiencing excessive workloads, and consider redistributing responsibilities where necessary.

3. **Strengthen early-tenure support:** Introduce structured onboarding, mentoring, regular check-ins and clear development plans for employees during their first two years.

4. **Improve employee satisfaction:** Investigate low job-satisfaction and work-life-balance scores through employee feedback, manager discussions and targeted workplace improvements.

5. **Establish continuous monitoring:** Regularly monitor attrition by department, job role, tenure, income group and overtime status to identify emerging retention risks.

### 5. Limitations

- The dataset represents a snapshot and does not establish the specific reasons why individual employees left.
- The analysis identifies associations rather than proving that a particular factor causes attrition.
- Some employee groups may have relatively small headcounts, so their attrition rates should be interpreted carefully.
- The findings reflect the available dataset and may not represent every organisation or workforce.

### Conclusion

The analysis identifies an overall attrition rate of 16.1%, with higher turnover among employees working overtime, employees in certain departments and job roles, and employees with shorter tenure or lower satisfaction scores.

These findings provide a starting point for targeted retention strategies. By investigating the underlying causes and monitoring workforce indicators regularly, HR teams can make more informed decisions and potentially improve employee retention.