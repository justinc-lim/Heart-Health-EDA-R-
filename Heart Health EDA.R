#### Heart Health EDA by Justin Lim

### This project explores and analyzes the Heart Health Dataset found at the following:
## https://www.kaggle.com/datasets/mahad049/heart-health-stats-dataset

## Main Question: How does bmi affect risk of hypertension?
## What about by gender? What about smoking?

# setwd("~/Data Projects") #Set Working Directory on my Local Computer
#install.packages("dplyr")
library(dplyr)

heart_health <- read.csv('Heart_health.csv')
head(heart_health)
dim(heart_health)
summary(heart_health)

#### Data Cleaning

# Convert Gender and Smoker inputs from characters to factors
heart_health$Smoker <- as.factor(heart_health$Smoker)
heart_health$Gender <- as.factor(heart_health$Gender)

# Separate Blood Pressure strings to read in as numeric
example <- heart_health$Blood.Pressure.mmHg.[1]
x<- strsplit(example, "/")
x[[1]][1]

len_dataset <- dim(heart_health)[1]

systolic_bp <- c()
for (i in c(1: len_dataset)) {
  bp <- heart_health$Blood.Pressure.mmHg.[i]
  sbp <- strsplit(bp, "/")[[1]][1]
  systolic_bp <- c(systolic_bp,sbp)
}
heart_health <- cbind(heart_health,systolic_bp)
heart_health$systolic_bp <- as.numeric(heart_health$systolic_bp)

diastolic_bp <- c()
for (i in c(1: len_dataset)) {
  bp <- heart_health$Blood.Pressure.mmHg.[i]
  dbp <- strsplit(bp, "/")[[1]][2]
  diastolic_bp <- c(diastolic_bp,dbp)
}

heart_health <- cbind(heart_health,diastolic_bp)
heart_health$diastolic_bp <- as.numeric(heart_health$diastolic_bp)

remove(x, systolic_bp, sbp, diastolic_bp, dbp)

## Separate Entries by American Heart Association Blood Pressure Categories
## https://www.heart.org/en/health-topics/high-blood-pressure/understanding-blood-pressure-readings

bp_cat <- c()

bp_cat[heart_health$systolic_bp < 120 
       & heart_health$diastolic_bp < 80] <- 'Normal'

bp_cat[heart_health$systolic_bp >= 120 & heart_health$systolic_bp <= 129
       & heart_health$diastolic_bp < 80] <- 'Elevated'

bp_cat[heart_health$systolic_bp >= 130 
       & heart_health$systolic_bp <= 139]<- 'Hypertension 1'
bp_cat[heart_health$diastolic_bp >= 80 & 
         heart_health$diastolic_bp <= 89]<- 'Hypertension 1'      

bp_cat[heart_health$systolic_bp >= 140
       | heart_health$diastolic_bp >= 90] <- 'Hypertension 2'

bp_cat[heart_health$systolic_bp >= 180
       | heart_health$diastolic_bp >= 120] <- 'Hypertension Crisis'

heart_health <- cbind(heart_health, bp_cat)
heart_health$bp_cat <- factor(heart_health$bp_cat,levels= c("Normal","Elevated", "Hypertension 1", 
                                                            "Hypertension 2", "Hypertension Crisis"))
remove(bp_cat)


## Calculate BMI, Separate Entries by BMI
# https://www.nhlbi.nih.gov/calculate-your-bmi 
# BMI = kg/m^2

heart_health$Height.cm. <- heart_health$Height.cm./100 # convert cm to m
heart_health <- heart_health %>% 
  rename(Height.m. = Height.cm.) # Rename column from cm to m

bmi <- c()

for (i in c(1: len_dataset)) {
  bmi_calc <- heart_health$Weight.kg[i]/ (heart_health$Height.m.[i])^2
  bmi <- c(bmi, bmi_calc)
}

heart_health <- cbind(heart_health,bmi)
remove(bmi)

bmi_cat <- c()
bmi_cat[heart_health$bmi < 18.5] <- 'Underweight'
bmi_cat[heart_health$bmi >= 18.5 & heart_health$bmi <= 24.9] <- 'Healthy'
bmi_cat[heart_health$bmi >= 25 & heart_health$bmi <= 29.9] <- 'Overweight'
bmi_cat[heart_health$bmi >= 30] <- 'Obese'

heart_health <- cbind(heart_health, bmi_cat)
heart_health$bmi_cat <- factor(heart_health$bmi_cat,levels= c("Underweight","Healthy", "Overweight", 
                                                            "Obese"))
remove(bmi_cat)

# Create Separate Dataset for Gender and Smoker

male_hh <- heart_health[which(heart_health$Gender == "Male"),]
female_hh <- heart_health[which(heart_health$Gender == "Female"),]

smoker_hh <- heart_health[which(heart_health$Smoker == "Yes"),]
nonsmoker_hh <- heart_health[which(heart_health$Smoker == "No"),]

##-------------------------------------------------------------------------------

## Question 1: What is the spread of hypertension across the dataset? 
barplot(summary(heart_health$bp_cat), ylim= c(0,300), xlab= "Blood Pressure Label", 
        ylab= "Frequency",main= "Spread of Hypertension across Dataset", 
        col= c('green','yellow','orange', 'red', 'red'))

## From the table, we see that the majority of our data falls
# between Normal and Hypertension 1. 

## Question 2: What is the spread of hypertension across the dataset by BMI?
hist(heart_health$bmi[heart_health$bp_cat == 'Normal'], freq= F, main= "Hypertension by BMI",
     ylim = c(0,3), xlim= c(22, 28), xlab= "BMI", col= rgb(0,1,0, 0.5))
hist(heart_health$bmi[heart_health$bp_cat == 'Elevated'], freq= F, col= rgb(1,1,0, 0.5), add=T)
hist(heart_health$bmi[heart_health$bp_cat == 'Hypertension 1'], freq= F, col= rgb(1,0,0, 0.5), add=T)

dens_norm <- density(heart_health[which(heart_health$bp_cat == 'Normal'),]$bmi, bw= 0.3)
dens_el <- density(heart_health[which(heart_health$bp_cat == 'Elevated'),]$bmi, bw= 0.3)
dens_h1 <- density(heart_health[which(heart_health$bp_cat == 'Hypertension 1'),]$bmi, bw= 0.3)

lines(dens_norm, col= rgb(0,1,0,1), lwd= 4)
lines(dens_el, col= rgb(1,1,0,1), lwd= 4)
lines(dens_h1, col= rgb(1,0,0,1), lwd= 4)

legend("topright", c("Normal", "Elevated", "Hypertension 1"), col=c(rgb(0,1,0,0.5),rgb(1,1,0,0.5),
                                                          rgb(1,0,0,0.5)), lwd=20)

## From the chart, we can see that the higher the BMI, the higher risk of hypertension 1.

###-------------------------------------------------------------------------------

## Question 2: What is the relationship between Elevated Blood Pressure and smoking?
# Question 2a: Is there a gender factor to this relationship?

# First, let's look at the relationship between smoking and blood pressure. 
# I've divided the dataset between smokers and non-smokers in the data cleaning proccess.

barplot(table(heart_health$Smoker),
        main= "Frequency chart of Smokers in our Dataset",
        ylim= c(0,400),
        ylab= "Frequency",
        xlab= "Is Smoker",
        col= c(rgb(1,0,0, 0.5), rgb(0,0,1, 0.5))
        )
## We have roughly the same amount of non-smokers as smokers.

par(mfrow= c(1,2))
barplot(table(smoker_hh$bp_cat)[c(1:3)],
        main= "Blood Pressure Categories",
        ylim= c(0,300),
        ylab= "Frequency",
        xlab= "Smoker",
        col= rgb(1,0,0,0.5)
        )
## I drop hypertension 2 and crisis because none in dataset

barplot(table(nonsmoker_hh$bp_cat)[c(1:3)],
        main= "by Smoker",
        ylim= c(0,300),
        ylab= "Frequency",
        xlab= "Nonsmoker",
        col= rgb(0,0,1,0.5)
)


## Interestingly, we see that Hypertension 1 is way higher in
## Non-smokers than in Smokers. Let's see the BMI range for
## the two categories.

par(mfrow= c(1,1))
hist(smoker_hh$bmi,
     freq= F, 
     breaks= 10,
     main= "Distribution of BMI by Smoker",
     xlab= "BMI",
     ylab= "Density",
     col= rgb(1, 0, 0, 0.25))

hist(nonsmoker_hh$bmi,
     freq= F, 
     breaks= 20, 
     add= T, 
     col= rgb(0, 0, 1, 0.25))
## Must use different break value because nonsmoker is bigger 

dens_smoker <- density(smoker_hh$bmi, bw= 0.5)
dens_nonsmoker <- density(nonsmoker_hh$bmi, bw= 0.5)

lines(dens_smoker, col=rgb(1, 0, 0, 1), lwd= 4)
lines(dens_nonsmoker, col=rgb(0, 0, 1, 1), lwd= 4)

legend("topright", c("Smoker", "NonSmoker"), 
       col=c(rgb(1,0,0,0.25),rgb(0,0,1,0.25), rgb(1,0,0,0.5)), lwd=20)

## From the graph, we see that Smoking and Non-Smoking have
## Similar BMI distributions. Smokers have slightly higher
## BMI measurements, but this does not explain why the
## Non-smokers in our dataset have higher rates of Hypertension.

table(smoker_hh$Gender)
table(nonsmoker_hh$Gender)

## From some quick table readings, we see that our Smoker data
## has more Male participants and vice versa for Nonsmokers.
## This raises the question: do Females have higher rates of
## Hypertension than Males?

## Note: It is still worth mentioning, our smoker table shows
## more elevated Blood Pressure than non-smokers. 

## Let's take a look at gender.
barplot(table(female_hh$bp_cat)[c(1:3)],
        main= "Blood Pressure by Gender",
        ylim= c(0,300),
        ylab= "Frequency",
        xlab= "Blood Pressure Category",
        col= rgb(1,0,0,0.25)
)
## Again, I drop hypertension 2 and crisis because none in dataset

barplot(table(male_hh$bp_cat)[c(1:3)],
        col= rgb(0,0,1,0.25),
        add= T
)


## As we can see, there hypertension is way higher in Males
## than in Females. Let's see what is happening in 
## our smoker datasets.

par(mfrow= c(1,2))
barplot(table(smoker_hh$bp_cat[which(smoker_hh$Gender == "Female")])[c(1:3)],
        main= "Blood Pressure by Gender",
        ylim= c(0,200),
        ylab= "Frequency",
        xlab= "Smoker",
        col= rgb(1,0,0,0.25)
)

barplot(table(smoker_hh$bp_cat[which(smoker_hh$Gender == "Male")])[c(1:3)],
        col= rgb(0,0,1,0.25),
        add= T
)

barplot(table(nonsmoker_hh$bp_cat[which(nonsmoker_hh$Gender == "Female")])[c(1:3)],
        main= "and Smoker",
        ylim= c(0,200),
        ylab= "Frequency",
        xlab= "Nonsmoker",
        col= rgb(1,0,0,0.25)
)

barplot(table(nonsmoker_hh$bp_cat[which(nonsmoker_hh$Gender == "Male")])[c(1:3)],
        col= rgb(0,0,1,0.25),
        add= T
)

legend("topright", c("Female", "Male"), 
       col=c(rgb(1,0,0,0.25),rgb(0,0,1,0.25), rgb(1,0,0,0.5)), lwd=20)

## As we can see from our graphs, the value of Hypertension 1
## in our Nonsmoker category is due to the overwhelming
## amount of Males with Hypertension. This is what we were seeing
## in our previous graph.

## These graphs prove that males have higher Blood Pressure
## readings than females. Yet, the effect of smoking is still
## undetermined. 

###-------------------------------------------------------------------------------


## Results:
## From our exploration of the dataset we found that:
## 1: Blood Pressure has a positive relationship with BMI, meaning
##    I found that it BP increases as BMI increases.
## 2: In our dataset, Males have a higher risk of 
##    elevated blood pressure and hypertension 1 than females.
## 3: The effect of smoking on blood pressure is undetermined,
##    the results of our analysis don't confirm a positive nor
##    negative relationship between smoking and blood pressure. 
