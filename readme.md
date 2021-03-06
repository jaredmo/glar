# General Ledger Analytics for R

A series of analytics for ERP general ledger data. Purpose is to identify data quality issues and unusual patterns.

***

## Getting Started

In order to run the analysis, you'll need RStudio with the following packages installed.
* ggplot2
* data.table
* readr

If you are new to R, follow the instructions below:
 1. Install RStudio from https://www.rstudio.com/
 2. Type the following into the console for each package listed above: install.packages("[package name]")

***
	 
### Quick start:

 1. Create a working directory (ex. C:\glar)
 2. Open import.r in RStudio
 3. Update setwd() with path
 4. Place gl.csv, tb.csv and coa.csv in root of working directory
 5. Open glar.Rmd in RStudio and click "Knit to HTML"
 6. Enjoy the results! 

***

### Input:

You will need to provide three .csv files: gl.csv, tb.csv, and coa.csv. Fields need to be in the order listed below. They are renamed on import, so header names are flexible. 
Data preparation procedures will likely be required for your specific ERP. Pre-reconciliation of the trial balance to journal line detail is also recommended.

**Journal lines (gl.csv) required fields:**

Field          | Type | Description
-------------- | ---- | ---------------------------------------
Journal ID     | chr  | Unique journal number
Description    | chr  | Transaction description
Fiscal Period  | chr  | Period of transaction	
Fiscal Year    | chr  | Year of transaction
Post Date      | date | Date of entry
Effective Date | date | Date effective on financials
User ID        | chr  | Preparer of transaction
Approver ID    | chr  | Approver of transaction
System/Manual  | chr  | System generated entry flag
Line Number    | chr  | Unique number for each Journal ID line
Account        | chr  | Ledger account
Amount         | num  | Amount of transaction
Dr Cr          | chr  | Debit/credit indicator

**Trial balance (tb.csv) required fields:**

Field             | Type | Description
----------------- | ---- | -------------------
Account           | chr  | Ledger account
Beginning Balance | num  | Balance at start of period
Ending Balance    | num  | Balance at end of period
		
**Chart of accounts (coa.csv) required fields:**

Field             | Type | Description
----------------- | ---- | -------------------
Account           | chr  | Ledger account

***

### Output:

Output from analytics below will available in the R Markdown file: glar.Rmd

	1. Reconciliation
		 a. Journal lines and trial balance net to 0
		 b. Journal lines and trial balance activity reconcile
	2. Summary Statistics
		 a. System/manual journal lines
		 b. Counts and amounts by user
		 c. Top amounts
	3. Data Quality Indicators
		 a. Journal lines with blank user
		 b. Journal lines with blank account
		 c. Journals that do not net to 0 
		 d. Journal lines with a negative debit or credit amount
		 e. Journal lines with a blank effective date
		 f. Journal lines with a blank posted date
		 g. Journal lines with blank entry description
		 h. Journal lines with an effective date outside test period
		 i. Percent of COA without activity
	4. Journal Analytics
		 a. Journal lines posted on weekends or holidays
		 b. Duplicate lines to the same account
		 c. Journal lines with same preparer and approver
		 d. Journal lines to unrelated accounts
		 e. Journal lines with blank or little description
		 f. Journal lines with key words in description
		 g. Journal lines with round dollar amount
		 h. Journal lines with recurring ending digits
		 i. Large credits to revenue at cutoff
		 j. Relationship between reserve and corresponding accounts
		 k. Effective date earlier than posted date (% of lines, >15, >30, >60, >90, >120)
		 l. Benford curve compared leading two digits  


## Author

Jared Monger
