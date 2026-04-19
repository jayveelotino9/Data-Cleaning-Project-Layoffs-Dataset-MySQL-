# Data-Cleaning-Project-Layoffs-Dataset-MySQL-
## Overview
This project focuses on cleaning a real-world layoffs dataset using MySQL. The goal was to prepare the raw data for analysis by removing duplicates, fixing inconsistencies, and handling missing values.

## Dataset
### Source: Alex The Analyst – MySQL YouTube Series
### Topic: Tech company layoffs data

## What I Did
1. Created a staging table — kept the original data untouched as a backup before making any changes.
2. Removed duplicates — used ROW_NUMBER() with a window function and CTE to identify and delete duplicate rows.
3. Standardized the data — trimmed whitespace from company names, unified industry labels (e.g. Crypto variants → one label), fixed a trailing period in country names, and converted the date column from text to a proper DATE type.
4. Handled NULLs and blanks — converted blank industry values to NULL, then used a self-join to fill them in where possible from matching company records.
5. Removed unusable rows — dropped rows where both total_laid_off and percentage_laid_off were NULL, since they'd be useless in any analysis.

## Tools Used
MySQL

### Notes
I followed along with Alex The Analyst's SQL tutorial series and used his dataset. This project helped me practice real data cleaning techniques in SQL.

