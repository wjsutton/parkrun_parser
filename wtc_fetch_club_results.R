
# Load libraries
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

# Load functions
#source("function_get_parkrun_results_links_from_cc_url.R")
#source("function_get_parkrun_cc_report_urls.R")
#source("function_extract_parkrun_result_urls.R")
source("parkrun_functions.R")

# Get a report for WTC (ClubNum=17417)
cc_url <- 'https://www.parkrun.com/results/consolidatedclub/?clubNum=17417'


all_urls <- get_parkrun_cc_report_urls(cc_url,10)

# Fetch only the results links from the consolidated club page
#latest_result_urls <- extract_parkrun_cc_report_urls(cc_url)
for(i in 3:length(all_urls)){
  latest_result_urls <- all_urls[i]
  
  # If there are results, extract them and filter for just Wakefield Triathlon Club 
  if(length(latest_result_urls)>0){
    latest_results <- extract_parkrun_cc_report_urls(latest_result_urls)
    wtc_latest_results <- dplyr::filter(latest_results,club=='Wakefield Triathlon Club')
  }
  
  # Save results to csv, if the results exist
  #if(exists(wtc_latest_results)){
    
    if(!file.exists("wtc_parkrun_report.csv")){
      write.csv(wtc_latest_results,"wtc_parkrun_report.csv",row.names = F)
    }
    
    if(file.exists("wtc_parkrun_report.csv")){
      wtc_results_df <- read.csv("wtc_parkrun_report.csv",stringsAsFactors = F)
      report_dates <- unique(wtc_results_df$date)
      new_date <- unique(wtc_latest_results$date)
      
      wtc_results_df <- filter(wtc_results_df,date!=new_date)
      wtc_results_merged <- rbind(wtc_results_df,wtc_latest_results)
      write.csv(wtc_results_merged,"wtc_parkrun_report.csv",row.names = F)
    }
  #}
}

