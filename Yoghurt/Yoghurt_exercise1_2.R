rm(list=ls())
setwd("~/Disk Google/Repositories/marketing-data-analysis/Yoghurt")
getwd()

#Installed packages
#install.packages("ggplot2")
#install.packages("corrplot")
#install.packages("lattice")


# Librarues
library(ggplot2)
library(corrplot)
library(lattice)

# Create data frame from a .csv file
yoghurt.df <- read.csv("Yoghurt_data.csv")
summary(yoghurt.df)
str(yoghurt.df)

# Assign labels to the factor variables
## Survey factor variables / for all row please factorize
for(i in 2:10) {yoghurt.df[, i] <- factor(yoghurt.df[, i], labels=c("strongly disagree", "disagree", "uncertain", "agree", "strongly agree"))}

  yoghurt.df$?..id <- factor(yoghurt.df$?..id)

## Socio-demographic factor variables
yoghurt.df$gender <- factor(yoghurt.df$gender, 
                            labels=c("male", "female"))
yoghurt.df$age <- factor(yoghurt.df$age, 
                            labels=c("18-24", "25-34", "35-44", "45-54", "55-64", "65+"))

yoghurt.df$ethnic <- (6 - yoghurt.df$ethnic)
yoghurt.df$ethnic[yoghurt.df$ethnic==4] <- 44
yoghurt.df$ethnic[yoghurt.df$ethnic==5] <- 4
yoghurt.df$ethnic[yoghurt.df$ethnic==44] <- 5

yoghurt.df$ethnic <- factor(yoghurt.df$ethnic,
                            labels=c("no answer", "other" ,"Hispanic origin", "Asian and Pacific Islander", "American Indian", "black","white"))
yoghurt.df$educatio <- factor(yoghurt.df$educatio,
                              labels=c("High School", "Some college", "Associate's Degree", "4-year College graduates", "Graduate Degree", "No answer"))
yoghurt.df$region <- factor(yoghurt.df$region,
                              labels=c("East", "Central", "South", "West"))
yoghurt.df$income <- factor(yoghurt.df$income,
                            labels=c("<15K", "15K-25K", "25K-35K", "35K-50K", "50K-75K", "75K-100K", "100K-150K", "150K-200K", ">200K", "No answer"))
save(yoghurt.df, file="~/Disk Google/Repositories/marketing-data-analysis/Yoghurt/yoghurt.RData")

load("yoghurt.RData")



# Examine the gender structure of the respondents
table(yoghurt.df$gender)
yog.gender.tab <- table(yoghurt.df$gender)
plot(yog.gender.tab)
prop.table(yog.gender.tab, margin=NULL)
yog.gender.tabS <- prop.table(yog.gender.tab, margin=NULL)

#Bar plot of frequencies
barplot(yog.gender.tab)

#  ggplot2: Bar plot of frequencies
ggplot(as.data.frame(yog.gender.tabS), aes(x=Var1, y = Freq, label=sprintf("%0.2f", round(Freq, digits = 2)))) + geom_bar(stat="identity", fill='grey', colour = 'grey')+labs(x="p1price", y="Frequency")+geom_text(size = 3, hjust=1.2)+coord_flip()
ggsave("yog_gender_bar.png")

# Side by side two-way bar plot of incomes distribution across genders
yog.gendinc.tab <- prop.table(table(yoghurt.df$income, yoghurt.df$gender))
yog.gendinc.tab <- prop.table(table(yoghurt.df$income, yoghurt.df$gender))*100
barplot(yog.gendinc.tab)
bp<-barplot(yog.gendinc.tab, beside=TRUE,
  col = c("purple", "red", "orange", "pink", "black", "blue", "cyan", "green", "yellow", "white"),
  xlab="Gender",
  ylab="Income share", legend=c("<15K", "15K-25K", "25K-35K", "35K-50K", "50K-75K", "75K-100K", "100K-150K", "150K-200K", ">200K", "No answer"),
  args.legend = list(title = "Income intervals", x = "top", cex = .7), ylim = c(0, 20))
#add labels above the bars
text(x=bp,y=yog.gendinc.tab, labels=round(yog.gendinc.tab, 1), cex=0.6, pos=3, xpd=NA)
png('yog_gendinc_bar.png')

#Lattice
histogram(~gender|income, data=yoghurt.df)
histogram(~gender|income, data=yoghurt.df, layout=c(5,2), col=c("burlywood", "darkolivegreen"))
histogram(~gender|income, data=yoghurt.df, layout=c(10,1), col=c("burlywood", "darkolivegreen"))
histogram(~state|income, data=yoghurt.df, col=c("burlywood", "darkolivegreen"))


yog.child.mean <- aggregate(children~ethnic, data=yoghurt.df, mean)
yog.child.median <- aggregate(children~ethnic, data=yoghurt.df, median)

bc <-barchart(ethnic~children, data=yog.child.mean, cex=0.5, col="grey")
bc

# Generate continuous variables
set.seed(1201)

## total spending for grocery
str(yoghurt.df)
nobs <- 2123
yoghurt.df$spend <- exp(rnorm(n=yoghurt.df$X...id, mean=(as.integer(yoghurt.df$income)/5), sd=0.5))*1000
yoghurt.df$spend <- round(yoghurt.df$spend, digits=2)
## total spending for yoghurt
yoghurt.df$yogspend <- exp(rnorm(n=yoghurt.df$X...id, mean=log(yoghurt.df$spend*0.1), sd=0.5))/10
yoghurt.df$yogspend <- round(yoghurt.df$yogspend, digits=2)

### simple scatterplot
plot(x=yoghurt.df$spend, y=yoghurt.df$yogspend)
### add axis labels
plot(x=yoghurt.df$spend, y=yoghurt.df$yogspend,
     main = "Weekly spending for grocery and yoghurt",
     xlab="Weekly spendings for grocery (USD)",
     ylab="Weekly spendings for yoghurt (USD)")
### separate by gender
my.col <- c("blue", "pink")
my.pch <- c(1, 19) #R's symbols for solid and open circles (see ?points)

my.col[as.numeric(tail(yoghurt.df$gender))]
my.col[tail(yoghurt.df$gender)]

plot(yoghurt.df$spend, yoghurt.df$yogspend,
     cex=0.7,
     col=my.col[yoghurt.df$gender], pch=my.pch[yoghurt.df$gender],
     main="Gender-specific spending for grocery and yoghurt",
     xlab="Weekly spendings for grocery (USD)",
     ylab="Weekly spendings for yoghurt (USD)")

#### Box-plot
boxplot(yoghurt.df$yogspend ~ yoghurt.df$gender, horizontal=TRUE,
        ylab="Gender", xlab="Weekly spending for yoghurt", las=1,
        main="Weekly Spending by State")

#### scatterplot matrix
pairs(formula=~spend + yogspend + children, data=yoghurt.df)

corrplot.mixed(corr=cor(yoghurt.df[,c(19,20)]))

plot(ecdf(yoghurt.df$spend),
     main="Cumulative distribution of spending for grocery",
     ylab="Cumulative Proportion",
     xlab=c("Weekly Spending, 90% <= 6896.578"),
     yaxt="n")

abline(h=0.9, lty=3)
abline(v=quantile(yoghurt.df$spend, pr=0.9), lty=3)


### Covariance and correlation computation
cov(yoghurt.df$spend, yoghurt.df$yogspend)
cov(yoghurt.df$spend, yoghurt.df$yogspend)/(sd(yoghurt.df$spend)*sd(yoghurt.df$yogspend))
cor(yoghurt.df$spend, yoghurt.df$yogspend)

qqnorm(yoghurt.df$spend)
qqline(yoghurt.df$spend)

qqnorm(yoghurt.df$yogspend)
qqline(yoghurt.df$yogspend)

yoghurt.df$logspend<-log(yoghurt.df$spend)
yoghurt.df$lgyspend<-log(yoghurt.df$yogspend)
qqnorm(yoghurt.df$logsped)
qqline(yoghurt.df$logsped)

cor(yoghurt.df$logspend, yoghurt.df$lgyspend)
plot(yoghurt.df$logspend, yoghurt.df$lgyspend)



