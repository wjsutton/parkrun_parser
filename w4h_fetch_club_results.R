
# Load libraries
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

# Load functions
source("function_get_parkrun_results_links_from_cc_url.R")
source("function_extract_parkrun_result_urls.R")

# Get a report for West 4 Harriers (ClubNum=1242)
cc_url <- 'https://www.parkrun.com/results/consolidatedclub/?clubNum=1242&eventdate=2020-03-14'

# Fetch only the results links from the consolidated club page
latest_result_urls <- get_parkrun_results_links_from_cc_url(cc_url)

# If there are results, extract them and filter for just West 4 Harriers
if(length(latest_result_urls)>0){
  latest_results <- extract_parkrun_result_urls(latest_result_urls)
  w4h_latest_results <- dplyr::filter(latest_results,club=='West 4 Harriers')
}

# Save results to csv, if the results exist
if(exists(w4h_latest_results)){
  
  if(!file.exists("w4h_parkrun_report.csv")){
    write.csv(w4h_latest_results,"w4h_parkrun_report.csv",row.names = F)
  }
  
  if(file.exists("w4h_parkrun_report.csv")){
    w4h_results_df <- read.csv("w4h_parkrun_report.csv",stringsAsFactors = F)
    report_dates <- unique(w4h_results_df$date)
    new_date <- unique(w4h_latest_results$date)
    
    w4h_results_df <- filter(w4h_results_df,date!=new_date)
    w4h_results_merged <- rbind(w4h_results_df,w4h_latest_results)
    write.csv(w4h_results_merged,"w4h_parkrun_report.csv",row.names = F)
  }
}
