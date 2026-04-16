## Business Problem

Which customers are most likely to default on loans?
What factors contribute to higher credit risk?
How can the bank reduce potential losses while maintaining loan growth?

## The dataset includes:

Customer demographics (age, income, employment status)
Loan details (loan amount, type, duration)
Credit history (past defaults, payment behavior)
Loan status (Default / Non-default)

## Tools & Technologies

SQL (data extraction, joins, aggregations)
Power BI (dashboard & visualization)
Excel (data cleaning & preprocessing)

## Data Preparation

Handled missing values in income and credit history
Standardized categorical fields (loan type, employment status)
Created derived columns:
Debt-to-Income Ratio
Risk Category (Low / Medium / High)
Loan-to-Income Ratio

## Analysis Performed

1. Default Rate Analysis
Calculated overall default rate
Compared default rates across:
Income groups
Loan sizes
Employment status

2. Risk Segmentation
Segmented customers into:
Low Risk
Medium Risk
High Risk
Based on:
Income level
Existing debt
Credit history

3. Loan Behavior Analysis
Analyzed relationship between:
Loan amount vs default rate
Income vs repayment behavior

4. Customer Profile Analysis
Identified high-risk customer profiles:
Low income + high loan amount
Poor credit history
Unstable employment

## Key Insights

Customers with high loan-to-income ratio show significantly higher default rates
Low-income segments are more likely to default
Borrowers with previous credit issues have a strong correlation with default
Large loans without proper income backing increase risk exposure

 ## Recommendations
Introduce stricter checks for high loan-to-income applicants
Implement risk-based pricing (higher interest for higher risk)
Prioritize approval for customers with:
Stable income
Strong credit history
Develop early warning systems for high-risk customers

## Dashboard Features (Power BI)
Default rate KPI
Risk segmentation visuals
Loan distribution analysis
Customer profile breakdown
Interactive filters (income, loan size, risk level)

## Dashboard Preview


<img width="1446" height="915" alt="Screenshot 2026-04-12 214159" src="https://github.com/user-attachments/assets/df4efebe-42e6-4dd6-acf8-0cf74ab67bdd" />
<img width="1437" height="911" alt="Screenshot 2026-04-12 214244" src="https://github.com/user-attachments/assets/5d32f468-6911-48f6-b7c0-63e4f9cebb54" />
<img width="1432" height="917" alt="Screenshot 2026-04-12 214300" src="https://github.com/user-attachments/assets/fd0e85dd-33ea-4dfd-ba83-3d6a08db9fb2" />

