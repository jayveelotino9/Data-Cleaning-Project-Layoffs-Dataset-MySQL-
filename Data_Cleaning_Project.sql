-- DATA CLEANING 
-- Shout out to the owner of the dataset (Alex the Analyst from Youtube) for this wonderful dataset from his YTC 

-- 0. Create table duplicate for layoff table staging 
-- 1. Remove Duplicates 
-- 2. Standardize data (Spellings, spaces etc.) (
-- 3. Null or Blank values
-- 4. Remove any columns (blank, irrelevant)

--  first is i did create a duplicate of table for staging.. since it is important to have a backup when doing these things
create table layoffs_staging
like layoffs;

insert layoffs_staging
select * from layoffs;

-- Remove Duplicates -- 2nd is to see if there are duplicates
-- I used row_number clause with window function to find duplicates with CTE
WITH CTE_duplicate as
(
select *, row_number () over(
partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_no
from layoffs_staging
 ) 
 select * from CTE_duplicate
 where row_no > 1;
 
 -- Since i can't do a delete statement on CTE, i will create a new copy that has rows
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_no` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 insert layoffs_staging2
 select *, row_number () over(
partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_no
from layoffs_staging;
 
 -- now, i will delete the duplicates
 DELETE from layoffs_staging2
 where row_no > 1;
 
 -- NOW DUPLICATES REMOVED!!!!
 
-- 2. Standardize data
-- first is to see everything if there is empty spaces and everything

select distinct company
from layoffs_staging2;

-- since there is empty spaces in company, i will trim it
UPDATE layoffs_staging2
SET company =  trim(company);

-- next is industry since location is alright
-- there are no empty spaces in industry, but there is a same one which is crypto and cryptocurrency a same industry
select distinct industry
from layoffs_staging2
order by 1;

-- i will update all crypto to become cryptocurrency
update layoffs_staging2
set industry = 'Crypto Currency'
where industry like 'Crypto%';

-- Now let's check it
select * 
from layoffs_staging2
where industry like 'Crypto%'; 

-- Since location is good, let's do country
select distinct country 
from layoffs_staging2
order by 1;

-- there are 2 united states in country, the one that is normal and the one that has a dot, im going to remove the dot
update layoffs_staging2
set country = 'United States'
where country like 'United States%';

-- or this that i learned from the internet where you just trim trail the dot itself, it think this might be easier in some cases
-- idk though since im still learning SQL but it's better to know a thing or 2 on some cases
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%'
;

-- Let's check it
select distinct country
from layoffs_staging2
order by 1;


-- Next is the date!
-- I want to change the date into Year/Month/Day which is the standard so i will use string to date
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

-- Now that i finally put it in standard, i will now update it
update layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y')
;
-- Now that it's on standard, i saw that the date is still on text, so i will modify the column into date
alter table layoffs_staging2
modify column `date` DATE;

-- Next is removing the row_no that we used for finding duplicates since we don't need it anymore
alter table layoffs_staging2
drop column row_no;


-- let's see in industry the blank or null ones
select * 
from layoffs_staging2
where industry is NULL
or industry = '';

-- UPDATE the blank ones into nulls first
update layoffs_staging2
set industry = NULL
where industry = ''
;
-- now, let's do a join to see if there are similar and we can populate it with other one
select t1.industry, t2.industry
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
where t1.industry is NULL 
and   t2.industry is not null 
;

-- now let's update it
update layoffs_staging2 t1
JOIN   layoffs_staging2 t2
	ON t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is NULL 
and  t2.industry is not null 
;

-- Now let's see if the industry has the same company or location that we can populate the industry
select * from layoffs_staging2
where industry is NULL
;
-- There is still one, but ball's inetractive company is only a single data, so we can't do anything anymore about it


-- now, since this is about layoffs, we will see the numbers on total laid off and percentage laidoff and see if we can remove some 
-- this is because when i do analysis, those who has no data might affect the analysis itself
select *, row_number () over()
from layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off is NULL
;

-- There are 361 rows that has no data about total_laid_off and percentage laid off, normally i will ask this to my supervisor
-- But since this is just a portfolio project of mine, Jayvee Lotino, we can just delete it and hypothetically our supervisor said yes

delete 
from layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off is NULL
;

-- NOW this is done data cleaned and that concludes my data cleaning project
-- Shout out to Alex the Analyst since i learned everything from him, from the SQL series, and this is also the data from him
