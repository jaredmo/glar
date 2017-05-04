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


# Use data.table
gl <- data.table(gl)
tb <- data.table(tb)


# Set rounding (1000 = Thousands, 1000000 = Millions)
div = 1000000


# 1a: Journal lines and trial balance net to 0
gl_sumtotal <- gl[, sum(amount, na.rm = TRUE)]
gl_linetotal <- gl[, .N]
gl_sum <- gl[, sum(amount, na.rm = TRUE), keyby = (jrnl_id)]
gl_unbal <- gl_sum[abs(V1) > 0.01]
colnames(gl_unbal)[2] <- "amount"
gl_txt <- paste("There are", gl_linetotal, "journal lines totaling", gl_sumtotal)
write_excel_csv(gl_unbal, path = "output/1a_gl_unbal.csv", na = "")
remove(gl_sum)

tb$period_act <- tb$end_bal - tb$beg_bal
tb_sumtotal <- tb[, sum(period_act, na.rm = TRUE)]
tb_linetotal <- tb[, .N]
tb_txt <- paste("There are", tb_linetotal, "trial balance lines totaling", tb_sumtotal)


# 1b: Journal lines and trial balance activity reconcile
gl_acctsum <- gl[, sum(amount, na.rm = TRUE), by = (account)]
recon <- merge(gl_acctsum, tb, by = "account", all = TRUE)
recon <- recon[abs(V1 - period_act) > 0.01]
recon <- recon[, c("account", "V1","period_act")]
colnames(recon)[2] <- "gl"
colnames(recon)[3] <- "tb"
recon$diff <- recon$tb - recon$gl


# 2a: System/manual journal lines
gl_sys <- gl[, .N, by = .(system, posting_yr, posting_pd)]
colnames(gl_sys)[1] <- "Systematic"
plot2a <- ggplot(gl_sys, aes(x = "", y = Systematic, fill = Systematic)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar(theta = "y", start = 0) +
  theme_void() +
  scale_fill_grey(start = .50, end = .70) +
  labs(
    title = "",
    caption = paste(man_flg, "= Manual;", sys_flg, "= Systematic"),
    x = "",
    y = ""
  )
plot2a


# 2b: Summary statistics by non-system user

gl_debits <- gl[amount > 0 & system == man_flg]
gl_credits <- gl[amount <= 0 & system == man_flg]
gl_debits <-
  gl_debits[, .(
    max = round(max(amount), -3) / div,
    sum = round(sum(amount), -3) / div,
    count = .N,
    mean = round(mean(amount), -3) / div
  ), keyby = .(user_id)]
gl_credits <-
  gl_credits[, .(
    min = round(min(amount), -3) / div,
    sum = round(sum(amount), -3) / div,
    count = .N,
    mean = round(mean(amount), -3) / div
  ), keyby = .(user_id)]

plot2b_dr <- ggplot(gl_debits, aes(mean, max)) +
  geom_point(size = 2) +
  labs(
    title = "Debit Lines by User",
    caption = "",
    x = "Mean Line",
    y = "Max Line"
  )

plot2b_cr <- ggplot(gl_credits, aes(mean, min)) +
  geom_point(size = 2)  +
  labs(
    title = "Credit Lines by User",
    caption = "",
    x = "Mean Line",
    y = "Max Line"
  )


# 4c: Journal lines with same preparer and approver
gl_users_dtl <-
  rbind(gl[apprvr_id == user_id], gl[is.na(apprvr_id)])
gl_users_dtl <- gl_users_dtl[system == man_flg]
gl_users <- gl_users_dtl[, .N, by = .(user_id,posting_yr,posting_pd)]
write_excel_csv(gl_users_dtl, path = "output/4c_gl_users_dtl.csv", na = "")
plot4c <- ggplot(gl_users, aes(x = reorder(user_id, -N), y = N)) +
  geom_bar(stat = "identity") + facet_grid(posting_yr + posting_pd ~ .) +
  labs(
    title = "",
    caption = "",
    x = "User",
    y = "Count"
  )
