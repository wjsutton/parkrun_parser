# Scheduled check that data has been imported on Sunday morning.
details <- read.csv(file = "gmail_details.csv")
sender <- details$email
client_id <- details$client_id
client_secret <- details$client_secret

report <- read.csv(file = "w4h_parkrun_report_all_runners.csv",stringsAsFactors = F)[ ,c('date')]
report_date <- max(report)
yesterday <- as.character(Sys.Date()-1)

if(report_date != yesterday){
  library(gmailr)
  
  gmail_auth(scope = "full",
             id = client_id,
             secret = client_secret, 
             secret_file = NULL)
  
  draft <- (mime(From=sender,
                 To=recipients,
                 Subject="Parkrun update failed",
                 body = paste0("The update for parkrun report ",yesterday," has failed.")))
  
  send_message(draft)
}
if(report_date == yesterday) {
  print("Nothing to worry about! :)")
}