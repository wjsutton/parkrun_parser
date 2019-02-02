#testing RSelenium

#url <- 'http://www.parkrun.org.uk/osterley/results/weeklyresults/?runSeqNumber=269'

library(RSelenium) 
library(XML)

rD <- rsDriver()
remDr <- rD[["client"]]
remDr$navigate(extract_link)
#remDr$navigate(url)

xml_test <- htmlParse(remDr$getPageSource()[[1]])
xml_test2 <- xpathSApply(xml_test,"//table/tbody/tr/td",xmlValue)
xml_test3 <- xml_test2[1:(length(xml_test2)-29)]

parkrun_results <- data.frame(matrix(unlist(xml_test3), ncol=11, byrow=T),stringsAsFactors=FALSE)
#names(parkrun_results) <- c("position","parkrunner","time","age_category","age_grade","gender","gender_position","club","note","total_runs","badges")

remDr$close()
# stop the selenium server
rD[["server"]]$stop() 

# if user forgets to stop server it will be garbage collected.
rm(rD)


