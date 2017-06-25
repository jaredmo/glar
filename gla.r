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
require(readr)
require(ggplot2)
require(data.table)


# Use data.table
gl <- data.table(gl)
tb <- data.table(tb)


# 1a: Journal lines and trial balance net to 0
gl_sumtotal <- gl[, sum(amount, na.rm = TRUE)]
gl_linetotal <- gl[, .N]
txt1a_gl <-
  paste("There are", gl_linetotal, "journal lines totaling", gl_sumtotal)

tb$period_act <- tb$end_bal - tb$beg_bal
tb_sumtotal <- tb[, sum(period_act, na.rm = TRUE)]
tb_linetotal <- tb[, .N]
txt1a_tb <-
  paste("There are",
        tb_linetotal,
        "trial balance lines totaling",
        tb_sumtotal)


# 1b: Journal lines and trial balance activity reconcile
gl_acctsum <- gl[, sum(amount, na.rm = TRUE), by = (account)]
recon <- merge(gl_acctsum, tb, by = "account", all = TRUE)
recon <- recon[abs(V1 - period_act) > 0.01]
recon <- recon[, c("account", "V1", "period_act")]
colnames(recon)[2] <- "gl"
colnames(recon)[3] <- "tb"
recon$diff <- recon$tb - recon$gl


# 2a: System/manual journal lines
gl_sys <- gl[, .N, by = .(system, posting_yr, posting_pd)]
colnames(gl_sys)[1] <- "Systematic"
plot2a <-
  ggplot(gl_sys, aes(x = "", y = Systematic, fill = Systematic)) +
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

plot2b_dr <-
  ggplot(gl_debits, aes(mean, max, label = as.character(user_id))) +
  geom_text(size = 3) +
  labs(
    title = "Debit Lines by User",
    caption = paste("Amounts divided by", div),
    x = "Mean Line",
    y = "Max Line"
  )
plot2b_dr

plot2b_cr <-
  ggplot(gl_credits, aes(mean, min, label = as.character(user_id))) +
  geom_text(size = 3)  +
  labs(
    title = "Credit Lines by User",
    caption = paste("Amounts divided by", div),
    x = "Mean Line",
    y = "Max Line"
  )
plot2b_cr

gl_top <-
  rbind(head(gl[order(-amount)], 10), head(gl[order(amount)], 10))
write_excel_csv(gl_top, path = "output/2b_gl_top.csv", na = "")


# 3a: Journal lines with blank user
txt3a_man <-
  paste("There are", gl[is.na(user_id) &
                          system == man_flg, .N], "manually generated lines with a blank user.")
txt3a_sys <-
  paste("There are", gl[is.na(user_id) &
                          system == sys_flg, .N], "system generated lines with a blank user.")


# 3b: Journal lines with blank account
txt3b_man <-
  paste("There are", gl[is.na(account) &
                          system == man_flg, .N], "manually generated lines with a blank account.")
txt3b_sys <-
  paste("There are", gl[is.na(account) &
                          system == sys_flg, .N], "system generated lines with a blank account.")


# 3c: Journals that do not net to 0
gl_unbal <- gl[, sum(amount, na.rm = TRUE), keyby = (jrnl_id)]
gl_unbal <- gl_unbal[abs(V1) > 0.01]
colnames(gl_unbal)[2] <- "amount"
write_excel_csv(gl_unbal, path = "output/3c_gl_unbal.csv", na = "")
txt3c <-
  paste("There are", gl_unbal[, .N], "journals that do not balance.")


# 3d: Journal lines with a negative debit or credit amount
txt3d_dr_man <-
  paste("There are",
        gl[amount < 0 &
             dr_cr == dr_flg &
             system == man_flg, .N],
        "manually generated lines with a negative debit amount.")
txt3d_dr_sys <-
  paste("There are",
        gl[amount < 0 &
             dr_cr == dr_flg &
             system == sys_flg, .N],
        "system generated lines with a negative debit amount.")
txt3d_cr_man <-
  paste("There are",
        gl[amount > 0 &
             dr_cr == cr_flg &
             system == man_flg, .N],
        "manually generated lines with a positive credit amount.")
txt3d_cr_sys <-
  paste("There are",
        gl[amount > 0 &
             dr_cr == cr_flg &
             system == sys_flg, .N],
        "system generated lines with a positive credit amount.")
gl_drcr_neg <-
  rbind(gl[amount < 0 & dr_cr == dr_flg & system == man_flg],
        gl[amount < 0 &
             dr_cr == dr_flg & system == sys_flg],
        gl[amount > 0 &
             dr_cr == cr_flg & system == man_flg],
        gl[amount > 0 &
             dr_cr == cr_flg & system == sys_flg])
write_excel_csv(gl_drcr_neg, path = "output/3d_gl_drcr_neg.csv", na = "")


# 3e. Journal lines with a blank effective date
txt3e <-
  paste("There are", gl[is.na(eff_date), .N], "lines with a blank effective date.")
write_excel_csv(gl[is.na(eff_date)], path = "output/3e_gl_effdt.csv", na = "")


# 3f. Journal lines with a blank posted date
txt3f <-
  paste("There are", gl[is.na(post_date), .N], "lines with a blank effective date.")
write_excel_csv(gl[is.na(post_date)], path = "output/3f_gl_postdt.csv", na = "")


# 3g. Journal lines with a blank entry description
txt3g <-
  paste("There are", gl[is.na(descp), .N], "lines with a blank entry description.")
write_excel_csv(gl[is.na(descp)], path = "output/3g_gl_blnkdesc.csv", na = "")


# 3h. Journal lines with an effective date outside test period
txt3h <-
  paste("There are",
        gl[eff_date < beg_dt | eff_date > end_dt, .N],
        "lines with an effective date outside test period.")
write_excel_csv(gl[eff_date < beg_dt |
                     eff_date > end_dt], path = "output/3h_gl_inveffdt.csv", na = "")


# 3i. Percent of COA without activity
gl_accts <- unique(gl, by = "account")
colnames(gl_accts)[11] <- "accountgl"

coa_accts <- unique(coa, by = "account")
colnames(coa_accts)[1] <- "accountcoa"

gl_accts <- data.table(gl_accts)
coa_accts <- data.table(coa_accts)
setkey(gl_accts, accountgl)
setkey(coa_accts, accountcoa)
coa_gl <- merge(coa_accts, gl_accts, by.x = "accountcoa", by.y = "accountgl", 
                all.x = TRUE)

coa_gl <- data.table(coa_gl)
coa_only <- sum(is.na(coa_gl$jrnl_id))
coa_tot <- coa_gl[, .N]
coa_perc <- round((coa_only / coa_tot) * 100, digits = 0)
coa_gl$Flag <- is.na(coa_gl$jrnl_id)
coa_gl <- within(coa_gl, Flag[is.na(coa_gl$jrnl_id)] <- "COA Only")
coa_gl <- within(coa_gl, Flag[!is.na(coa_gl$jrnl_id)] <- "Account Used")
coa_out <- coa_gl[, jrnl_id:=NULL]
colnames(coa_out)[1] <- "Account"
coa_out <- coa_out[, c("Account", "Flag")]
write_excel_csv(coa_out, path = "output/3i_coa_unused.csv", na = "")

plot3i <-
  ggplot(coa_gl, aes(x = factor(""), fill = Flag)) +
  geom_bar() +
  coord_polar(theta = "y") +
  scale_x_discrete("") +
  theme_void() +
  scale_fill_grey(start = .50, end = .70) +
  labs(
    title = "",
    caption = paste(coa_perc, "% of accounts in COA were not used during period."),
    x = "",
    y = ""
  )
plot3i


# 4c: Journal lines with same preparer and approver
gl_users_dtl <-
  rbind(gl[apprvr_id == user_id], gl[is.na(apprvr_id)])
gl_users_dtl <- gl_users_dtl[system == man_flg]
gl_users <-
  gl_users_dtl[, .N, by = .(user_id, posting_yr, posting_pd)]
write_excel_csv(gl_users_dtl, path = "output/4c_gl_users_dtl.csv", na = "")
plot4c <- ggplot(gl_users, aes(x = reorder(user_id, -N), y = N)) +
  geom_bar(stat = "identity") + facet_grid(posting_yr + posting_pd ~ .) +
  labs(
    title = "",
    caption = "",
    x = "User",
    y = "Count"
  )
plot4c
