library(dplyr)
library(tidyr)
library(ggplot2)
library(ggmap)
library(maps)
library(reshape2)
library(gridExtra)
library(VGAM)
library(hett)
library(MASS)
library(lme4)
library(devtools)
library(wordcloud2)
library(openintro)
library(knitr)

#######################
###### DATA INPUT #####
#######################
Loan1517 <- read.table("Loan1517.csv", header = TRUE, sep = ",")
Loan0711 <- read.table("Loan0711.csv", header = TRUE, sep = ",")
Loan1517$year <- ifelse(Loan1517$term == "36",3,5)
Loan0711$year <- ifelse(Loan0711$term == "36",3,5)
Loan0711$default <- ifelse(Loan0711$loan_status == "Fully Paid",0,1)
Loan1517$region <- tolower(Loan1517$region)
Loan0711$region <- tolower(Loan0711$region)
Loan0711$dti <- Loan0711$dti/100
Loan1517$dti <- Loan1517$dti/100

################
##### EDA0 #####
################
grid.arrange(
  ggplot(Loan1517)+
    aes(x=log(loan_amnt),fill = factor(year))+
    geom_density(alpha=0.3)+
    xlab("Loan Amount (log scale)")+
    labs(title="Loan Term (year)")+
    scale_fill_discrete(name = "Loan Term"),
  ggplot(Loan0711)+
    aes(x=log(loan_amnt),fill = factor(default))+
    geom_density(alpha=0.3)+
    xlab("Loan Amount (log scale)")+
    labs(title="Default")+
    scale_fill_discrete(name = "Default"),ncol=2)
grid.arrange(
  ggplot(Loan1517)+
    aes(x=log(loan_amnt),fill = home_ownership)+
    geom_density(alpha=0.3)+
    xlab("Loan Amount (log scale)")+
    labs(title="Home Ownership")+
    scale_fill_discrete(name = "Home Ownership"),
  ggplot(Loan1517)+
    aes(x=log(loan_amnt),fill = purpose)+
    geom_density(alpha=0.3)+
    xlab("Loan Amount (log scale)")+
    labs(title="Loan Purpose")+
    scale_fill_discrete(name = "Loan Purpose"),ncol=2)
grid.arrange(
  ggplot(Loan1517)+
    aes(x=log(loan_amnt),fill = factor(emp_year))+
    geom_density(alpha=0.3)+
    xlab("Loan Amount (log scale)")+
    labs(title="Employment Year")+
    scale_fill_discrete(name = "Employment Year"),
  ggplot(Loan1517)+
    aes(x=log(loan_amnt),fill = addr_state)+
    geom_density(alpha=0.3)+
    xlab("Loan Amount (log scale)")+
    labs(title="State")+
    scale_fill_discrete(name = "state")+
    theme(legend.position="none"),
  ncol=2)

################
##### EDA1 #####
################
ggplot(Loan1517)+
  aes(x=log(loan_amnt),fill = grade)+
  geom_density(alpha=0.3)+
  xlab("Loan Amount (log scale)")+
  labs(title="Loan Amount")

grid.arrange(
  ggplot(Loan1517)+
    aes(x=log(monthly_inc),fill = grade)+
    geom_density(alpha=0.3)+
    xlab("Monthly Income (log scale)")+
    labs(title="Monthly Income"),
  ggplot(Loan1517)+
    aes(x=log(monthly_inc),fill = grade)+
    geom_density(alpha=0.3)+
    xlim(6,12)+
    xlab("Monthly Income (log scale)")+
    labs(title="Monthly Income (Remove outliers)"),
  ncol=2
)


ggplot(NULL)+
  aes(grade)+
  geom_bar(aes(y = (..count..)/sum(..count..),fill = factor(year)),data = subset(Loan1517,year == 3),alpha=0.5)+
  geom_bar(aes(y = (..count..)/sum(..count..),fill = factor(year)),data = subset(Loan1517,year == 5),alpha=0.5)+
  scale_y_continuous(labels = scales::percent)+
  ylab("Percentage")+
  labs(title="Loan Term")+
  scale_fill_discrete(name = "Loan Term (year)")

ggplot(NULL)+
  aes(grade)+
  geom_bar(aes(y = (..count..)/sum(..count..),fill = home_ownership),
           data = subset(Loan1517,home_ownership == "RENT"),alpha=0.5)+
  geom_bar(aes(y = (..count..)/sum(..count..),fill = home_ownership),
           data = subset(Loan1517,home_ownership == "MORTGAGE"),alpha=0.5)+
  geom_bar(aes(y = (..count..)/sum(..count..),fill = home_ownership),
           data = subset(Loan1517,home_ownership == "OWN"),alpha=0.5)+
  scale_y_continuous(labels = scales::percent)+
  ylab("Percentage")+
  labs(title="Home Ownership")+
  scale_fill_discrete(name = "Home Ownership")

##################
##### model1 #####
##################
model2_0<- polr(grade ~ log(loan_amnt) + year + log(monthly_inc) + home_ownership + emp_year + purpose + addr_state, 
                data = Loan1517)
summary(model2_0)
model2_1<- polr(grade ~ log(loan_amnt) + year + log(monthly_inc) + home_ownership,  data = Loan1517)
summary(model2_1)

################
##### EDA2 #####
################
ggplot(Loan0711)+aes(x=grade,fill=factor(default))+
  geom_bar(position="fill")+
  labs(title = "Default or not in each grade")+
  ylab("Default rate")+xlab("Grade")+
  scale_fill_discrete(name = "Default")+
  theme(plot.title = element_text(hjust = 0.5))

ggplot(Loan0711)+aes(x=grade,fill=factor(default))+
  geom_bar(position="fill")+
  labs(title = "Default or not in each grade")+
  ylab("Default rate")+xlab("Grade")+facet_wrap( ~ purpose, ncol = 4)+
  scale_fill_discrete(name = "Default")+
  theme(plot.title = element_text(hjust = 0.5))

ggplot(Loan0711)+aes(x=grade,fill=factor(default))+
  geom_bar(position="fill")+
  labs(title = "Default or not in each grade")+
  ylab("Default rate")+xlab("Grade")+facet_wrap( ~ addr_state, ncol = 9)+
  scale_fill_discrete(name = "Default")+
  theme(plot.title = element_text(hjust = 0.5))

##################
##### Model2 #####
##################
model3_0 <- glm(default ~ gradenum + dti, family=binomial, data = Loan0711)
summary(model3_0)
mmps(model3_0)
binnedplot(fitted(model3_0),residuals(model3_0,type="response"))
Loan0711$fitted3_0 <- fitted(model3_0)
errorrate_model3_0 <- nrow(subset(Loan0711,fitted3_0>0.5&default==0|fitted3_0<0.5&default==1))/nrow(Loan0711)

model3_1 <- glmer(default ~ gradenum + dti + (1|purpose), family=binomial(link="logit"), data = Loan0711)
binnedplot(fitted(model3_1),residuals(model3_1,type="response"))
Loan0711$fitted3_1 <- fitted(model3_1)
errorrate_model3_1 <- nrow(subset(Loan0711,fitted3_1>0.5&default==0|fitted3_1<0.5&default==1))/nrow(Loan0711)

model3_2 <- glmer(default ~ gradenum + dti + (1|addr_state), family=binomial(link="logit"), data = Loan0711)
binnedplot(fitted(model3_2),residuals(model3_2,type="response"))
Loan0711$fitted3_2 <- fitted(model3_2)
errorrate_model3_2 <- nrow(subset(Loan0711,fitted3_2>0.5&default==0|fitted3_2<0.5&default==1))/nrow(Loan0711)

model3_3 <- glmer(default ~ gradenum + dti + (1|purpose) + (1|addr_state), family=binomial(link="logit"), data = Loan0711)
binnedplot(fitted(model3_3),residuals(model3_3,type="response"))
Loan0711$fitted3_3 <- fitted(model3_3)
errorrate_model3_3 <- nrow(subset(Loan0711,fitted3_3>0.5&default==0|fitted3_3<0.5&default==1))/nrow(Loan0711)

######################
##### Prediction #####
######################
Loan0711$prob <- predict(model3_3, Loan0711 ,type="response")
Loan0711$Predict <- as.factor(ifelse(Loan0711$prob>0.5,1,0))
ggplot(Loan0711)+aes(x=grade,fill=factor(Predict))+
  geom_bar(position="fill")+
  labs(title = "Predict Default or not for each grade in 2007-2011")+
  ylab("Default rate")+xlab("Grade")+
  scale_fill_discrete(name = "Default")+
  theme(plot.title = element_text(hjust = 0.5))
uniquepurpose <- data.frame(purpose = unique(Loan0711$purpose))
uniquestate <- data.frame(addr_state = unique(Loan0711$addr_state))
pred1517 <- merge(merge(Loan1517,uniquestate,by = "addr_state", all.y= TRUE),uniquepurpose)
pred1517$prob <- predict(model3_3, pred1517 ,type="response")
pred1517$Predict <- as.factor(ifelse(pred1517$prob>0.5,1,0))
ggplot(pred1517)+aes(x=grade,fill=factor(Predict))+
  geom_bar(position="fill")+
  labs(title = "Predict Default or not for each grade in 2015-2017")+
  ylab("Default rate")+xlab("Grade")+
  scale_fill_discrete(name = "Default")+
  theme(plot.title = element_text(hjust = 0.5))
