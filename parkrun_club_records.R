library(dplyr)
report <- read.csv('w4h_parkrun_report.csv',stringsAsFactors = F)
year <- substr(report$date,1,4)
report <- cbind(report,year)

all_time_best_by_ac <- report %>% 
                      group_by(age_category) %>% 
                      arrange(time) %>% 
                      mutate(rank = order(time))

all_time_best_by_ac  <- all_time_best_by_ac %>% filter(rank==1)

best_by_ac_yr <- report %>% 
  group_by(age_category, year) %>% 
  arrange(time) %>% 
  mutate(rank = order(time))

best_by_ac_yr <- best_by_ac_yr %>% filter(rank==1)

best_by_ac_pkr <- report %>% 
  group_by(age_category, parkrun) %>% 
  arrange(time) %>% 
  mutate(rank = order(time))

best_by_ac_pkr <- best_by_ac_pkr %>% filter(rank==1)

best_by_ac_pkr_yr <- report %>% 
  group_by(age_category, parkrun, year) %>% 
  arrange(time) %>% 
  mutate(rank = order(time))

best_by_ac_pkr_yr <- best_by_ac_pkr_yr %>% filter(rank==1)

by_ac_df1 <- data.frame(course='Any',year_option='All time',all_time_best_by_ac, stringsAsFactors = F)
by_ac_df2 <- data.frame(course='Any',year_option=best_by_ac_yr$year,best_by_ac_yr, stringsAsFactors = F)
by_ac_df3 <- data.frame(course=best_by_ac_pkr$parkrun,year_option='All time',best_by_ac_pkr, stringsAsFactors = F)
by_ac_df4 <- data.frame(course=best_by_ac_pkr_yr$parkrun,year_option=best_by_ac_pkr_yr$year,best_by_ac_pkr_yr, stringsAsFactors = F)

by_ac_df <- rbind(by_ac_df1,by_ac_df2,by_ac_df3,by_ac_df4)

write.csv(by_ac_df,"w4h_parkrun_records.csv", row.names = F)

library(googlesheets)
suppressMessages(library(dplyr))
gs_auth(token = "googlesheets_token.rds")
gs_upload("w4h_parkrun_records.csv", sheet_title = "w4h_parkrun_records",overwrite = TRUE)
