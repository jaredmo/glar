# =====================================================================
# File:            import.r
# Title:           General Ledger Analytics for R
# Author:          Jared Monger
# Create date:     4/25/17
# Input(s):        gl.csv, tb.csv, coa.csv (See readme.md)
# Description:     Import files
# =====================================================================


# Load required packages
require(readr)


# Set working directory
setwd('G:/My Documents/GitHub/glar')
getwd()


# Set system/manual variables
sys_flg <- "S"
man_flg <- "N"


# Set debit/credit variables
dr_flg <- "D"
cr_flg <- "C"


# Set test period
beg_dt <- as.Date("2017-01-01")
end_dt <- as.Date("2017-03-31")


# Set rounding (1000 = Thousands, 1000000 = Millions)
div = 1000000


# Create output folder
dir.create(file.path(getwd(), "output"), showWarnings = FALSE)


# Import gl.csv data
gl <-
  read_csv(file = "gl.csv",
           na = c("", "NA"),
           col_names = TRUE,
           col_types = cols())

tb <-
  read_csv(file = "tb.csv",
           na = c("", "NA"),
           col_names = TRUE,
           col_types = cols())

coa <-
  read_csv(file = "coa.csv",
           na = c("", "NA"),
           col_names = TRUE,
           col_types = cols())


# Clean import headers and field formats
colnames(gl)[1] <- "jrnl_id"
colnames(gl)[2] <- "descp"
colnames(gl)[3] <- "posting_pd"
colnames(gl)[4] <- "posting_yr"
colnames(gl)[5] <- "post_date"
colnames(gl)[6] <- "eff_date"
colnames(gl)[7] <- "user_id"
colnames(gl)[8] <- "apprvr_id"
colnames(gl)[9] <- "system"
colnames(gl)[10] <- "jrnl_line_nbr"
colnames(gl)[11] <- "account"
colnames(gl)[12] <- "amount"
colnames(gl)[13] <- "dr_cr"
gl$jrnl_id <- as.character(gl$jrnl_id)
gl$descp <- as.character(gl$descp)
gl$posting_pd <- as.character(gl$posting_pd)
gl$posting_yr <- as.character(gl$posting_yr)
gl$post_date <- as.Date.POSIXct(gl$post_date)
gl$eff_date <- as.Date.POSIXct(gl$eff_date)
gl$user_id <- as.character(gl$user_id)
gl$apprvr_id <- as.character(gl$apprvr_id)
gl$system <- as.character(gl$system)
gl$jrnl_line_nbr <- as.character(gl$jrnl_line_nbr)
gl$account <- as.character(gl$account)
gl$amount <- as.numeric(gl$amount)
gl$dr_cr <- as.character(gl$dr_cr)
head(gl, 0)

colnames(tb)[1] <- "account"
colnames(tb)[2] <- "beg_bal"
colnames(tb)[3] <- "end_bal"
tb$account <- as.character(tb$account)
tb$beg_bal <- as.numeric(tb$beg_bal)
tb$end_bal <- as.numeric(tb$end_bal)
head(tb, 0)

colnames(coa)[1] <- "account"
coa$account <- as.character(coa$account)
head(coa, 0)


