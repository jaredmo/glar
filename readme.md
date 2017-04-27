UPDATE 4/26/17: Version 1.0 of this project is in active development.


# General Ledger Analytics for R

A series of analytics for ERP general ledger data. Purpose is to identify data quality issues and unusual patterns.


## Getting Started

In order to run the analytics, you'll need R with the following packages installed. https://www.rstudio.com/
- ggplot2
- data.table
- readr

If you are new to R, follow the instructions below:
 1. Install RStudio from here: https://www.rstudio.com/
 2. Type the following into the console for each package listed above: install.packages("[package name]")

	 
### Quick start:

 1. Create a working directory (ex. C:\glar)
 2. Open gla.r in RStudio
 3. Update setwd() with new path
 4. Click "Source" (Ctrl + Shift + S) to run
 5. Follow prompt in placement of input files. See specifics below.


### Input:

You will need to provide three .csv files: gl.csv, tb.csv, and coa.csv. They will need to contain the fields below. 
Actual ERP field names will vary depending on the system, so data prep procedures will be required.
Pre-reconciliation of the trial balance to ledger detail is also recommended.

Journal lines (gl.csv) required fields:
 1. jrnl_id <chr> 
 2. descp <chr> 
 3. posting_pd <chr>
 4. posting_yr <chr>
 5. post_date <dttm>
 6. eff_date <dttm>
 7. user_id <chr>
 8. apprvr_id <chr>
 9. system <chr>
10. jrnl_line_nbr <chr>
11. account <chr>
12. amount <dbl>
13. dr_cr <chr>
14. origin_code <chr>

Trial balance (tb.csv) required fields:
 1. account <chr>
 2. beg_bal <dbl>
 3. period_act <dbl>
 4. end_bal <dbl>
		
Chart of accounts (coa.csv) required fields:
 1. account <chr>


### Output:

Output from analytics will be either plots or output in .csv format. Below are descriptions of the tests. All tests divided between system and manual entries.

[To be completed...]

	1. Reconciliation
		 1. Prompt: Entries and trial balance net to 0
		 2. Prompt: Entries and trial balance activity reconcile
	2. Summary Statistics
		 1. System/manual entries (pie chart)
		 2. Amounts by user
		 3. Top amounts
	3. Data Quality Indicators
		 1. Entries with blank user
		 3. Entries with blank account
		 4. Entries that do not net to 0 
		 5. Entries with an invalid effective date
		 6. Entries with an effective date outside test period
		 7. Entries with a negative debit or credit amount
		 8. Entries with a blank posted date
		 9. Entries with blank entry description
		11. Percent of COA without activity
	4. Journal Analytics
		 1. Entries posted on weekends or holidays
		 2. Duplicate lines to the same account
		 3. Entries with same preparer and approver	- DONE!	
		 4. Entries to unrelated accounts
		 5. Entries with blank or little description
		 6. Entries with key words in description
		 7. Entries with round dollar amount
		 8. Entries with recurring ending digits
		 9. Large credits to revenue at cutoff
		10. Relationship between reserve and corresponding accounts
		11. Effective date earlier than posted date (% of lines, >15, >30, >60, >90, >120)
		12. Benford curve compared leading two digits


## Author

Jared Monger