# Takes a list of parkrun results urls of the form:
# https://www.parkrun.org.uk/hanworth/results/weeklyresults/?runSeqNumber=46

# Load Libraries
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

extract_parkrun_result_urls <- function(result_urls) {
  stopifnot(length(result_urls)>0)
  
  for(i in seq(result_urls)){
    
    # check link is a results link
    if(!grepl('results',result_urls[i])){
      print(paste0(Sys.time(),",ERROR: link ",i,", ",result_urls[i]," is not a parkrun results link."))
    }
    
    print(paste0(Sys.time(),", starting extracting link ",i,", ",result_urls[i]))
    extract_link <- result_urls[i]
    
    # removing dashes in parkrun name because they fail ,e.g. black-park
    extract_link <- gsub('black-park','blackpark',extract_link)
    
    # converting http: to https:
    extract_link <- ifelse(substr(extract_link,1,5)=="http:",paste0("https",substr(extract_link,5,nchar(extract_link))),extract_link)
    
    # handling polish parkrun links
    if (grepl("parkrun.pl/",extract_link)) {
      extract_link <- gsub('/results/','/rezultaty/',extract_link)
    }
    
    Sys.sleep(25)
    go_to_link <- getURL(extract_link)
    link_xml <- read_html(go_to_link)
    title <- as.character(html_nodes(link_xml,"h1")[1])
    number_and_date <- as.character(html_nodes(link_xml,"h3")[1])
    date <- substr(number_and_date,5,str_locate(number_and_date,"<span")-1)
    
    parkrun <- as.character(substr(title,5,str_locate(title,'</')-1))
    number <- as.integer(substr(number_and_date,str_locate(number_and_date,"#")+1,str_locate(number_and_date,"</span>\n")-1))
    parkrun_table <- readHTMLTable(go_to_link)
    
    # if the results page is blank, and this is the latest result week then try latest results page
    if(length(is.na(parkrun_table$`NULL`))==0 & date>=(Sys.Date()-7)){
      latest_results_page <- paste0(substr(extract_link,1,str_locate(extract_link,'/results/')[2]),'latestresults/')
      
      Sys.sleep(25)
      go_to_link <- getURL(latest_results_page)
      link_xml <- read_html(go_to_link)
      title <- as.character(html_nodes(link_xml,"h1")[1])
      number_and_date <- as.character(html_nodes(link_xml,"h3")[1])
      date <- substr(number_and_date,5,str_locate(number_and_date,"<span")-1)
      
      parkrun <- as.character(substr(title,5,str_locate(title,'</')-1))
      number <- as.integer(substr(number_and_date,str_locate(number_and_date,"#")+1,str_locate(number_and_date,"</span>\n")-1))
      parkrun_table <- readHTMLTable(go_to_link)
    }
    
    if(is.data.frame(parkrun_table$`NULL`)) {
      parkrun_results <- parkrun_table$`NULL`
    }
    parkrun_results <- parkrun_results %>% mutate_if(is.factor, as.character)
    
    # Converting all df names to english version
    names(parkrun_results) <- c("Position","parkrunner","Gender","Age Group","Club","Time")
    
    # extracting results from parkrun_results
    parkrunner_name <- substr(parkrun_results$parkrunner,1,str_locate(parkrun_results$parkrunner,'\\d{1}')-1)
    parkrun_results$parkrunner_name <- ifelse(is.na(parkrunner_name),"Unknown",parkrunner_name)
    
    parkrun_results$total_runs <- as.integer(substr(parkrun_results$parkrunner,str_locate(parkrun_results$parkrunner,'\\d+'),str_locate(parkrun_results$parkrunner,'\n')-2))
    parkrun_results$age_category <- str_extract(parkrun_results$parkrunner,'..\\d{2}-\\d{2}')
    parkrun_results$age_grade <- paste0(str_extract(parkrun_results$parkrunner,'\\d{2}[.]\\d{2}'),'%')
    parkrun_results$gender_type <- gsub("\\s+|\\d", "",parkrun_results$Gender)
    parkrun_results$gender_type <- substr(parkrun_results$gender_type,1,1)
    parkrun_results$gender_position <- as.integer(str_extract(parkrun_results$Gender,'\\d{1,6}'))
    
    parkrun_results$parkrunner_time <- substr(parkrun_results$Time,1,str_locate(parkrun_results$Time,'[:alpha:]')-1)
    parkrun_results$note <- substr(parkrun_results$Time,str_locate(parkrun_results$Time,'[:alpha:]'),nchar(parkrun_results$Time))
    parkrun_results$badges <- NA
    
    parkrun_df <- cbind(parkrun, number, date, parkrun_results)
    parkrun_df <- parkrun_df[,c("parkrun","number","date","Position","parkrunner_name","parkrunner_time","age_category","age_grade","gender_type","gender_position","Club","note","total_runs","badges")]
    names(parkrun_df) <- c("parkrun","number","date","position","parkrunner","time","age_category","age_grade","gender","gender_position","club","note","total_runs","badges")
    
    parkrun_df$parkrun <- as.character(parkrun_df$parkrun)
    parkrun_df$date <- as.character(parkrun_df$date)
    parkrun_df$date <- paste0(substr(parkrun_df$date,7,10),"-",substr(parkrun_df$date,4,5),"-",substr(parkrun_df$date,1,2))
    
    if (exists('full_df')){
      full_df <- rbind(full_df,parkrun_df)
    }
    
    if (!exists('full_df')){
      full_df <- parkrun_df
    } 
    print(paste0(Sys.time(),", url ",i,", ",result_urls[i]," done!"))
  }
  print(paste0(Sys.time(),", all results extracted, tidying up results."))
  
  # spliting and fixing times
  unknowns <- full_df %>% filter(full_df$time=='')
  knowns <- full_df %>% filter(full_df$time!='')
  knowns_5 <- knowns %>% filter(nchar(as.character(knowns$time))==5)
  knowns_7 <- knowns %>% filter(nchar(as.character(knowns$time))==7)
  knowns_5$time <- paste0('00:',knowns_5$time)
  
  if (nrow(knowns_7)!=0){
    knowns_7$time <- paste0('0',knowns_7$time)
    full_df <- rbind(knowns_5,knowns_7,unknowns)
  }
  if (nrow(knowns_7)==0) {
    full_df <- rbind(knowns_5,unknowns)
  }
  
  return(full_df)
}
