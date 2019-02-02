source("parkrun_functions.R")

# backup report and find latest date
file.copy('w4h_parkrun_report.csv','backup_w4h_parkrun_report.csv',overwrite = TRUE)
file.copy('w4h_parkrun_report_all_runners.csv','backup_w4h_parkrun_report_all_runners.csv',overwrite = TRUE)

report <- read.csv('w4h_parkrun_report.csv',stringsAsFactors = F)
report$date <- as.Date(report$date)
report_date <- max(report$date)

report_all <- read.csv('w4h_parkrun_report_all_runners.csv',stringsAsFactors = F)
report_all$date <- as.Date(report_all$date)

# get newest consolidated club report
new_data <- extract_parkrun_cc_report_urls('http://www.parkrun.com/results/consolidatedclub/?clubNum=1242')
new_data$date <- as.Date(new_data$date)
new_date <- max(new_data$date)

if(new_date>report_date){
  w4h_new_data <- new_data %>% dplyr::filter(new_data$club=='West 4 Harriers')
  report <- rbind(report,w4h_new_data)
  write.csv(report,'w4h_parkrun_report.csv',row.names = FALSE)
  
  report_all <- rbind(report_all,new_data)
  write.csv(report_all,'w4h_parkrun_report_all_runners.csv',row.names = FALSE)
  
  library(googlesheets)
  suppressMessages(library(dplyr))
  gs_auth(token = "googlesheets_token.rds")
  gs_upload("w4h_parkrun_report.csv", sheet_title = "w4h_parkrun_report",overwrite = TRUE)
}