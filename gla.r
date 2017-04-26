# =====================================================================
# File:            gla.r
# Title:           General Ledger Analytics for R
# Author:          Jared Monger
# Create date:     4/25/17
# Input(s):        gl.csv, tb.csv, coa.csv (See readme.md)
# Description:     A series of analytics for ERP general ledger data. 
#                  Purpose is to identify data quality issues and 
#                  unusual patterns.
# =====================================================================


# Load required packages
require(ggplot2)
require(data.table)
require(readr)


# Set working directory
setwd('G:/My Documents/GitHub/glar')
getwd()


# Create input and output folders
dir.create(file.path(getwd(), "input"), showWarnings = FALSE)
dir.create(file.path(getwd(), "output"), showWarnings = FALSE)
readline(prompt =
           "Place gl.csv, tb.csv, and coa.csv in input folder. Press [enter] to continue.")


# Import gl.csv data
gl_raw <-
  read_csv(file = "input/gl.csv",
           na = c("", "NA"),
           col_names = TRUE)

tb_raw <-
  read_csv(file = "input/tb.csv",
           na = c("", "NA"),
           col_names = TRUE)


# Clean import headers and field formats
colnames(gl_raw)[1] <- "jrnl_id"
colnames(gl_raw)[2] <- "descp"
colnames(gl_raw)[3] <- "posting_pd"
colnames(gl_raw)[4] <- "posting_yr"
colnames(gl_raw)[5] <- "post_date"
colnames(gl_raw)[6] <- "eff_date"
colnames(gl_raw)[7] <- "user_id"
colnames(gl_raw)[8] <- "apprvr_id"
colnames(gl_raw)[9] <- "system"
colnames(gl_raw)[10] <- "jrnl_line_nbr"
colnames(gl_raw)[11] <- "account"
colnames(gl_raw)[12] <- "amount"
colnames(gl_raw)[13] <- "dr_cr"
colnames(gl_raw)[14] <- "origin_code"
gl_raw$jrnl_id <- as.character(gl_raw$jrnl_id)
gl_raw$descp <- as.character(gl_raw$descp)
gl_raw$posting_pd <- as.character(gl_raw$posting_pd)
gl_raw$posting_yr <- as.character(gl_raw$posting_yr)
gl_raw$post_date <- as.Date.POSIXct(gl_raw$post_date)
gl_raw$eff_date <- as.Date.POSIXct(gl_raw$eff_date)
gl_raw$user_id <- as.character(gl_raw$user_id)
gl_raw$apprvr_id <- as.character(gl_raw$apprvr_id)
gl_raw$system <- as.character(gl_raw$system)
gl_raw$jrnl_line_nbr <- as.character(gl_raw$jrnl_line_nbr)
gl_raw$account <- as.character(gl_raw$account)
gl_raw$amount <- as.numeric(gl_raw$amount)
gl_raw$dr_cr <- as.character(gl_raw$dr_cr)
gl_raw$origin_code <- as.character(gl_raw$origin_code)
head(gl_raw, 0)

colnames(tb_raw)[1] <- "account"
colnames(tb_raw)[2] <- "beg_bal"
colnames(tb_raw)[3] <- "period_act"
colnames(tb_raw)[4] <- "end_bal"
tb_raw$account <- as.character(tb_raw$account)
tb_raw$beg_bal <- as.numeric(tb_raw$beg_bal)
tb_raw$period_act <- as.numeric(tb_raw$period_act)
tb_raw$end_bal <- as.numeric(tb_raw$end_bal)
head(tb_raw, 0)



# Use data.table
gl_raw <- data.table(gl_raw)
tb_raw <- data.table(tb_raw)


# 1.1 Prompt: Entries and trial balance net to 0
gl_sumtotal <- gl_raw[, sum(amount, na.rm = TRUE)]
gl_linetotal <- gl_raw[, .N]
gl_sum <- gl_raw[, sum(amount, na.rm = TRUE), keyby = (jrnl_id)]
gl_unbal <- gl_sum[abs(V1) > 0.01] #Unbalanced journals
colnames(gl_unbal)[2] <- "amount"
write_excel_csv(gl_unbal, path = "output/gl_unbal.csv", na = "")
remove(gl_sum)
tb_sumtotal <- tb_raw[, sum(period_act, na.rm = TRUE)]
tb_linetotal <- tb_raw[, .N]
readline(prompt =
           "Verify gl_sumtotal and tb_sumtotal are 0. Press [enter] to continue.")


# 1.2 Prompt: Entries and trial balance activity reconcile


# 4.3 Entries with same preparer and approver
gl_users_dtl <-
  rbind(gl_raw[apprvr_id == user_id], gl_raw[is.na(apprvr_id)])
gl_users_dtl <- gl_users_dtl[system == "N"]
gl_users <- gl_users_dtl[, .N, keyby = user_id]
write_excel_csv(gl_users_dtl, path = "output/gl_users_dtl.csv", na = "")
ggplot(gl_users, aes(x = reorder(user_id,-N), y = N)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Entries with same preparer and approver",
    caption = "",
    x = "User",
    y = "Count"
  )
