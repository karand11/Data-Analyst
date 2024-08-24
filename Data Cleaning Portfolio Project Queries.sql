-- Data Cleaning USING SQL

select * 
from layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
select * 
from layoffs;


select company 
from layoffs_staging;


-- STEP 1 -------Removing Duplicates

select *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry,total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions) AS row_num
from layoffs_staging;


WITH duplicate_cte AS
(
select *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry,total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions) AS row_num
from layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
where company = 'Casper';

-- Now because in sql update and delete doesnt work because of of it there is no actual row_num in the table, 
-- so we just have to insert the column in the table(by creating a duplicate table of this and adding the actual row_num in the table)




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
	`row_column` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry,total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions) AS row_num
from layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_column > 1;

DELETE
FROM layoffs_staging2
WHERE row_column > 1;


-- Just altering the colunm name from row_column to row_num
ALTER TABLE layoffs_staging2
rename column row_column TO row_num;

-- STEP 2 ------- Standardizing Data (which means each and every column)

SELECT *
FROM layoffs_staging2;

SELECT company, Trim(company)
from layoffs_staging2;

-- Standardizing  company

SELECT DISTINCT company
FROM layoffs_staging2;


-- Standarding column industry
 
SELECT distinct industry
from layoffs_s taging2
order by 1;

select *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standarding column location

SELECT distinct location
FROM layoffs_staging2
order by 1;

-- Standarding column country

SELECT distinct country
FROM layoffs_staging2
order by 1;

select * 
from layoffs_staging2
where country like 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Now Standardizing Date (its in text convert into date format and standardize by using m-d-y for the time series visualization)

SELECT date,
str_to_date(date,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = str_to_date(date,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY column `date` DATE;


-- STEP 3 REMOVING BLANK AND NULL FROM THE DATASET

-- DELETING THE DATA WHICH HAS NULL IN BOTH total_laid off and percentage_laid_off that has no use bacause the whole reason is the table is related to layoff if the number doesnt exist then whats the point of keeping it in the table

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

-- REMOVING NULL FROM THE INDUSTRY BY USING JOIN 

select *
from layoffs_staging2
where company ='Airbnb';

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

SELECT industry
FROM layoffs_staging2
where industry IS NULL 
OR industry = '';

SELECT t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company AND t1.location=t2.location
where t1.industry IS NULL 
and t2.industry is not null;

UPDATE layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company=t2.company AND t1.location=t2.location
SET t1.industry=t2.industry
where t1.industry IS NULL 
and t2.industry is not null;


-- STEP 4 DROP THE COLUMN WHICH WE CREATED TO SEE IF THERE IS ANY DUPLICATES IN THE DATASET(WHICH IS row_num)

ALTER TABLE layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;













