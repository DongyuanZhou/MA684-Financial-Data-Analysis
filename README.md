# MA684-Project: Financial data analysis
Dongyuan Zhou
## Background
In the financial field, making decisions on whether to lend money to borrowers is one of the most important work. A whole cycle of this work usually includes the following two steps. 

Firstly, grades the loan according to the borrower credit record as well as the loan amount and loan time, and then make decision whether lend or not.

Secondly, summarize the default rate and improve the former step to avoid default next time.

## Goals

In this analysis, we analyze data from Lending club (LC):

**Stage1: Before loan was funded (Data: 2015-2017)**

Analyze how LC assigned loan grade: How borrower's status as well as the loan amount and loan time influenced loan grade? (Multinomial regression)

**Stage2: After loan ended (Data: 2007-2011)**

Analyze the relationship between loan grade and default rate (Multilevel logistic regression)

**Stage3: After loan ended (Data: 2015-2017)**

Predict the default rate for loan in 2015-2017

**Stage4: Summarize and Discussion**

Assessment of	the	result. Discuss about the data limitations and future	directions.

## Data description
Data source: [_https://www.lendingclub.com/info/download-data.action_](https://www.lendingclub.com/info/download-data.action)

To get reasonable analysis, we only choose the data which had been verified by LC.

## Analysis
### 0. Loan amount
Before we do any analysis or fit any models, it is interesting to show the loan amount request distribution in our data. Although we cannot go deeper analysis for this topic with the data we have so far, in the industry, this could help the company deciding the asset allocation and portfolio management. 

As shown in the plot above: 

Higher loan amount request always have longer loan term;

Borrowers who work for more than 10 years or just participant in their career have larger loan amount request;

Borrowers whose home is mortgage have larger loan amount request;

The loan amount seems lower for the vacation purpose and higher for the debt consolidation purpose;

Loan with large amount seems more likely to be default in the end.

All these information is important for the portfolio manager after the company lend out the money as well as receive the loan.

### 1. Before loan was funded

We use the data from 2015 to 2017 analyzing how LC assigned loan grade. To be more specific, we try to fit models to show how borrower's status as well as the loan amount and loan time influenced loan grade? (Multinomial regression)

#### Initial EDA: 
From the chart above, we could see that:

Higher loan amount, lower loan grade; 

Longer loan term, lower loan grade;

Lower income, lower loan grade; 

Home ownership as mortgage has higher grade.

It is reasonable to consider borrower's state, employment year and loan purpose as factors, since there is financial environment difference in different state, and longer employment year seems to have more stable income.

However, there is not much significant difference according the EDA for those three factors. 

Maybe we could use the multilevel regression to show the result.

#### Model

We fit a linear model to show the relationship between loan amount and borrower's status as well as the loan amount and loan term.

**polr(grade ~ log(loan_amnt) + year + log(monthly_inc) + home_ownership + emp_year + purpose + addr_state)**

Check residuals: Residual Deviance: 567279.20 

AIC: 567425.20 

Interpret:

We get the coefficient of employment length that is positive and insignificant contrary to our expectation. It seems reasonable to remove this variable from our model. 

Meanwhile, loan purpose and state of loan has little significance compared to monthly income and loan amount.

Therefore, we consider a new model for the grade of loan as a function of loan amount, loan term and borrower's monthly income as well as home ownership.

**polr(grade ~ log(loan_amnt) + year + log(monthly_inc) + home_ownership)**

Check residuals: Residual Deviance: 575377.17 

AIC: 575395.17 

Then we made a [shiny app](https://dongyuanzhou.shinyapps.io/Loan_grade_shiny/) to simulate how LC assigned loan grade using the new model.


### 2. After loan ended

We use data from 2007 to 2011 analyzing the relationship between whether default or not and loan grade. (Multilevel logistic regression)

#### Initial EDA

We could see that loans with lower grade seems have higher probability to be default.

What's more, whether default or not with the same loan grade is different in each state and for various loan purpose. We are not sure if these factors is important so far, and we could include these factors as the group level in our model later to see the result.

#### Model

Our main objective is to find out whether we can use the loan grade to predict the loan might be default or not. 

Besides the loan grade, our predictors also include debt to income ratio.
We fit a logistic model to show the quantitative relationship between whether default or not and loan grade. Besides the loan grade and debt to income ratio, we add loan purpose and state as the group level, which include the information of different purpose and state's random effect to our model outcome.

**glm(default ~ gradenum + dti, family=binomial)**

From the binned residual plot, we could see a disturbing pattern, with an extreme positive and negative residual in the middle bin: people in the middle bin are more or less likely to default than is predicted by the model.

The error rate for the model is 16%.

1 sd increase in debt-to-income ratio has a multiple effect of exp(0.01)=1.01 on odds od default,controling grade in same level.

The odds ratio of default for grade A vs grade G is exp(1.8)= 6.05

The loan in grade B is 0.75/4=19% more likely to default than loan in grade A.

The loan in grade C is 1.13/4=28% more likely to default than loan in grade A.

The loan in grade D is 1.38/4=35% more likely to default than loan in grade A.

The loan in grade E is 1.70/4=43% more likely to default than loan in grade A.

The loan in grade F is 1.94/4=49% more likely to default than loan in grade A.

The loan in grade G is 1.82/4=46% more likely to default than loan in grade A.

Since state and purpose may also has influence on the default rate, we fit multilevel model to see if there is some difference between state as well as purpose.

**glmer(default ~ gradenum + dti + (1|purpose) + (1|addr_state), family=binomial(link="logit"))**

### 3. After loan ended (Data: 2015-2017)

Predict the default rate for loan in 2015-2017.

### 4. Discussion

**Result**

From this analysis report, we could know that the loan grade is significantly related to loan amount and loan term. What's more, if borrower had another mortgage, the grade would be higher as expected. This is reasonable, since their credit quality had checked by other institutions. However, the employment year is not such related as common sense, and this is a point that could be analyze deeper.

For default rate, the higher grade reflect the lower default rate. What's more, the initial debt to income ratio is also important. From the analysis, we could give suggestion that grade F and grade G has really high default rate, and reject their loan request may be a better desicion.

**Data limitation**

Since the credit information is private, we cannot track the whole process for each loan. 

What's more, the FICO Score should be an important predictor in this analysis,however, since it is personal privacy, we could not get the data. Therefore, just consider about the factor as home ownership and income has its limitation.

Finally, since the financial market and the interest rate policy has changed during years, credit quality could not be the only factor of default. Other investment chances and bank loan should be considered and the time span is important.

**Future directions**

Combine the bank interest rate in each year's analysis is what we could consider deeper, and basic financial knowledge is required.
Moreover, since the loan is always span 3-5 years or more, maybe we could track the result years later.

# Appendix and reference

Data source: [_https://www.lendingclub.com/info/download-data.action_](https://www.lendingclub.com/info/download-data.action)

Code for data cleaning: ["data clean.R"](https://github.com/DongyuanZhou/MA684-Project/blob/master/data%20clean.R)

Code and output for model: 

pdf file:
