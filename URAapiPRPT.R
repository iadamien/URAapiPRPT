list.of.packages <- (c("httr","jsonlite","stringr","dplyr","tidyr","lubridate"))
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

invisible(lapply(list.of.packages,library, character.only = TRUE))

#insert access key here between the quotes
accesskey<-""

tokenurl <- "https://www.ura.gov.sg/uraDataService/insertNewToken.action"
get_token <- GET(tokenurl, add_headers(AccessKey = accesskey))
get_token_text <- content(get_token,"text", encoding = "UTF-8")
token <- strsplit(get_token_text, split = '["]')[[1]][4]

df_api = data.frame()

for (i in 1:4) {
  apiurl <- paste("https://www.ura.gov.sg/uraDataService/invokeUraDS?service=PMI_Resi_Transaction&batch=",i,sep="")
  apicont <- GET(apiurl, add_headers(AccessKey = accesskey, Token = token))
  apicont_text <- content(apicont, "text", encoding = "UTF-8")
  
  api_json <-fromJSON(apicont_text, flatten = TRUE)
  df_api <- rbind(df_api,unnest(api_json$Result,transaction)) 
}

write.csv(df_api, paste("URAPRPRT - ",Sys.Date(), ".csv", sep = ""), quote = FALSE, row.names = FALSE)
paste("You can find your output file in ",getwd())