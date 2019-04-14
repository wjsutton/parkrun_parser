#setwd("C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser")
source("C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/parkrun_functions.R")

# backup report and find latest date
file.copy('C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report.csv','C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/backup_w4h_parkrun_report.csv',overwrite = TRUE)
file.copy('C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report_all_runners.csv','C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/backup_w4h_parkrun_report_all_runners.csv',overwrite = TRUE)

report <- read.csv('C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report.csv',stringsAsFactors = F)
report$date <- as.Date(report$date)
report_date <- max(report$date)

report_all <- read.csv('C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report_all_runners.csv',stringsAsFactors = F)
report_all$date <- as.Date(report_all$date)

# get newest consolidated club report
new_data <- extract_parkrun_cc_report_urls('https://www.parkrun.com/results/consolidatedclub/?clubNum=1242')
new_data$date <- as.Date(new_data$date)
new_date <- max(new_data$date)

if(new_date>report_date){
  w4h_new_data <- new_data %>% dplyr::filter(new_data$club=='West 4 Harriers')
  report <- rbind(report,w4h_new_data)
  write.csv(report,'C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report.csv',row.names = FALSE)
  
  report_all <- rbind(report_all,new_data)
  write.csv(report_all,'C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report_all_runners.csv',row.names = FALSE)
  
  library(googlesheets)
  suppressMessages(library(dplyr))
  gs_auth(token = "C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/googlesheets_token.rds")
  gs_upload("C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/w4h_parkrun_report.csv", sheet_title = "w4h_parkrun_report",overwrite = TRUE)
}