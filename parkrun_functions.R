
library(rvest)
library(RCurl)
library(stringr)
library(XML)
library(dplyr)

extract_parkrun_cc_report_urls <- function(urls) {
  
  for(a in 1:length(urls)){
    url <- paste0(urls[a])
  
  page <- getURL(url[length(url)])
  date <- as.Date(substr(page,
                         str_locate_all(page,'who participated at a parkrun on ')[[1]][1,2]+1,
                         str_locate_all(page,'who participated at a parkrun on ')[[1]][1,2]+10))
  page <- read_html(page)
  
  links <- html_nodes(page, "p a")
  num_of_links <- length(links)
  min <- 3
  max <- num_of_links-2
  
  Sys.sleep(10)
  
  if(min<=max){
    
    for(i in min:max){
      print(i)
      extract_link <- substr(links[i],
                             str_locate_all(links[i],'"')[[1]][1]+1,
                             str_locate_all(links[i],'"')[[1]][2]-1)
      # removing dashes in parkrun name because they fail ,e.g. black-park
      extract_link <- gsub('black-park','blackpark',extract_link)
      
      # converting http: to https:
      extract_link <- ifelse(substr(extract_link,1,5)=="http:",paste0("https",substr(extract_link,5,nchar(extract_link))),extract_link)
      
      # handling polish parkrun links
      if (substr(extract_link,19,21)=='.pl') {
        extract_link <- gsub('/results/','/rezultaty/',extract_link)
      }
      
      Sys.sleep(25)
      go_to_link <- getURL(extract_link)
      link_xml <- read_html(go_to_link)
      title <- html_nodes(link_xml,"h2")
      
      parkrun <- as.character(substr(title,5,str_locate(title,'#')[1]-2))
      number <- as.integer(str_extract(str_extract(title,'\\d{1,6} '),'\\d{1,6}'))
      parkrun_table <- readHTMLTable(go_to_link)
      
      # if the results page is blank, and this is the latest result week then try latest results page
      if(length(is.na(parkrun_table$`results`))==0 & date>=(Sys.Date()-7)){
        latest_results_page <- paste0(substr(extract_link,1,str_locate(extract_link,'/results/')[2]),'latestresults/')
        
        Sys.sleep(25)
        go_to_link <- getURL(latest_results_page)
        link_xml <- read_html(go_to_link)
        title <- html_nodes(link_xml,"h2")
        
        parkrun <- as.character(substr(title,5,str_locate(title,'#')[1]-2))
        number <- as.integer(str_extract(str_extract(title,'\\d{1,6} '),'\\d{1,6}'))
        parkrun_table <- readHTMLTable(go_to_link)
      }
    
      if(is.na(nrow(parkrun_table$`results`))){
        source("C:/Users/sutto/Documents/Scheduled Tasks/Parkrun Parser/rselenium_workaround.R")
      }
      
      if(is.data.frame(parkrun_table$`results`)) {
        parkrun_results <- parkrun_table$`results`
      }
      parkrun_results <- parkrun_results %>% mutate_if(is.factor, as.character)
      
      # handling French parkrun reports
      # e.g. http://www.parkrun.fr/boisdeboulogne/results/weeklyresults/?runSeqNumber=126
      if(ncol(parkrun_results)==9){
        #removing entries with no time
        parkrun_results <- parkrun_results %>% dplyr::filter(parkrun_results$V2!='')
        
        # adding positions
        parkrun_results <- parkrun_results[order(parkrun_results$V2),]
        pos <- c(1:nrow(parkrun_results))
        parkrun_results <- cbind(pos,parkrun_results)
        
        # splitting to male and female to determine gender position
        m_parkrun_results <- parkrun_results %>% dplyr::filter(parkrun_results$V5=='M')
        g_pos <- c(1:nrow(m_parkrun_results))
        m_parkrun_results <- cbind(m_parkrun_results[,1:6],g_pos,m_parkrun_results[,7:10])
        
        f_parkrun_results <- parkrun_results %>% dplyr::filter(parkrun_results$V5=='F')
        g_pos <- c(1:nrow(f_parkrun_results))
        f_parkrun_results <- cbind(f_parkrun_results[,1:6],g_pos,f_parkrun_results[,7:10])
        
        #merging dataframe back together
        parkrun_results <- rbind(m_parkrun_results,f_parkrun_results)
      }
      
      names(parkrun_results) <- c("position","parkrunner","time","age_category","age_grade","gender","gender_position","club","note","total_runs","badges")
      
      parkrun_df <- cbind(parkrun, number, date, parkrun_results)
      parkrun_df <- parkrun_df %>% dplyr::mutate(parkrun = as.character(parkrun),
                                                 number = as.integer(number),
                                                 position = as.integer(position),
                                                 gender_position = as.integer(gender_position),
                                                 total_runs = as.integer(total_runs),
                                                 badges = as.integer(badges))
      # removing leading and trailing whitespace
      parkrun_df$parkrun <- gsub("^\\s+|\\s+$", "",parkrun_df$parkrun)
      
      if (!exists('full_df')){
        full_df <- parkrun_df
      } else {
      full_df <- rbind(full_df,parkrun_df)
      }
    }
  }
  print(paste0(a," parkrun reports done!"))
  }
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

get_parkrun_cc_report_urls <- function(url,i) {
  report_links <- url
  if(i>1){
    repeat {
      Sys.sleep(30)
      page <- getURL(report_links[length(report_links)])
      page <- read_html(page)
      
      links <- html_nodes(page, "p a")
      num_of_links <- length(links)
      
      prev_rep <- substr(links[num_of_links-1],
                         str_locate_all(links[num_of_links-1],'"')[[1]][1]+1,
                         str_locate_all(links[num_of_links-1],'"')[[1]][2]-1)
      prev_rep <- gsub("amp;",'',prev_rep)
      
      report_links <- c(report_links,prev_rep)
      print(paste0(length(report_links)," done!"))
      if(length(report_links)==i){
        break
      }
    }
  }
  return(report_links)
}
