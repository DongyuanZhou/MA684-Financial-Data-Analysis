## read the data
## 2007-2011
Loan0711data <- subset(read.table("LoanStats_07_11.csv", header = TRUE, sep = ",", skip = 1, nrows = 39786), 
                       verification_status == "Verified")
## 2016-2017
Loan1601 <- subset(read.table("LoanStats_2016Q1.csv", header = TRUE, sep = ",", skip = 1, nrows = 133887), 
                   verification_status == "Verified")
Loan1602 <- subset(read.table("LoanStats_2016Q2.csv", header = TRUE, sep = ",", skip = 1, nrows = 97854), 
                   verification_status == "Verified")
Loan1603 <- subset(read.table("LoanStats_2016Q3.csv", header = TRUE, sep = ",", skip = 1, nrows = 99120), 
                   verification_status == "Verified")
Loan1604 <- subset(read.table("LoanStats_2016Q4.csv", header = TRUE, sep = ",", skip = 1, nrows = 103546), 
                   verification_status == "Verified")
Loan1701 <- subset(read.table("LoanStats_2017Q1.csv", header = TRUE, sep = ",", skip = 1, nrows = 96779), 
                   verification_status == "Verified")
Loan1702 <- subset(read.table("LoanStats_2017Q2.csv", header = TRUE, sep = ",", skip = 1, nrows = 105451), 
                   verification_status == "Verified")
Loan1703 <- subset(read.table("LoanStats_2017Q3.csv", header = TRUE, sep = ",", skip = 1, nrows = 122701), 
                   verification_status == "Verified")
## Select the column
Loan0711 <- na.omit(Loan0711data[ ,c(3,6,7,9,10,12,13,14,16,17,21,24,25)])
Loan1517 <- na.omit(rbind.data.frame(Loan1601,Loan1602,Loan1603,Loan1604,Loan1701,Loan1702,Loan1703)[ ,c(3,6,7,9,10,12,13,14,16,17,21,24,25,61,65)])
## Transform the data type
Loan1517$emp_year <- ifelse(Loan1517$emp_length == "< 1 year",0,
                            ifelse(Loan1517$emp_length == "1 year",1,
                                   ifelse(Loan1517$emp_length == "2 years",2,
                                          ifelse(Loan1517$emp_length == "3 years",3,
                                                 ifelse(Loan1517$emp_length == "4 years",4,
                                                        ifelse(Loan1517$emp_length == "5 years",5,
                                                               ifelse(Loan1517$emp_length == "6 years",6,
                                                                      ifelse(Loan1517$emp_length == "7 years",7,
                                                                             ifelse(Loan1517$emp_length == "8 years",8,
                                                                                    ifelse(Loan1517$emp_length == "9 years",9,
                                                                                           ifelse(Loan1517$emp_length == "10+ years",10,NA)))))))))))
Loan0711$emp_year <- ifelse(Loan0711$emp_length == "< 1 year",0,
                            ifelse(Loan0711$emp_length == "1 year",1,
                                   ifelse(Loan0711$emp_length == "2 years",2,
                                          ifelse(Loan0711$emp_length == "3 years",3,
                                                 ifelse(Loan0711$emp_length == "4 years",4,
                                                        ifelse(Loan0711$emp_length == "5 years",5,
                                                               ifelse(Loan0711$emp_length == "6 years",6,
                                                                      ifelse(Loan0711$emp_length == "7 years",7,
                                                                             ifelse(Loan0711$emp_length == "8 years",8,
                                                                                    ifelse(Loan0711$emp_length == "9 years",9,
                                                                                           ifelse(Loan0711$emp_length == "10+ years",10,NA)))))))))))
## NA
Loan0711 <- na.omit(Loan0711)
Loan1517 <- na.omit(Loan1517)
## Transform the grade num
Loan1517$gradenum <- ifelse(Loan1517$grade == "A",7,
                            ifelse(Loan1517$grade == "B",6,
                                   ifelse(Loan1517$grade == "C",5,
                                          ifelse(Loan1517$grade == "D",4,
                                                 ifelse(Loan1517$grade == "E",3,
                                                        ifelse(Loan1517$grade == "F",2,1))))))
Loan0711$gradenum <- ifelse(Loan0711$grade == "A",7,
                            ifelse(Loan0711$grade == "B",6,
                                   ifelse(Loan0711$grade == "C",5,
                                          ifelse(Loan0711$grade == "D",4,
                                                 ifelse(Loan0711$grade == "E",3,
                                                        ifelse(Loan0711$grade == "F",2,1))))))
Loan0711$grade <- ordered(Loan0711$grade, levels=c("A", "B", "C", "D", "E", "F", "G"))
Loan1517$grade <- ordered(Loan1517$grade, levels=c("A", "B", "C", "D", "E", "F", "G"))
## Transform the income into monthly
Loan0711$monthly_inc <- Loan0711$annual_inc/12
Loan1517$monthly_inc <- Loan1517$annual_inc/12
Loan1517 <- subset(Loan1517, Loan1517$home_ownership != "ANY")
## add region
Loan1517$region <- abbr2state(Loan1517$addr_state)
Loan0711$region <- abbr2state(Loan0711$addr_state)
## Final data
write.csv(Loan0711,"Loan0711old.csv")
write.csv(Loan1517,"Loan1517old.csv")