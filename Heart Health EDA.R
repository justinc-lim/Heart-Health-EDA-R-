#### Heart Health EDA by Justin Lim

### This project explores and analyzes the Heart Health Dataset found at the following:
## https://www.kaggle.com/datasets/mahad049/heart-health-stats-dataset

## Main Question: How does bmi affect risk of hypertension?
## What about by gender? What about smoking?

setwd("~/Data Projects") #Set Working Directory on my Local Computer
#install.packages("dplyr")
library(dplyr)

heart_health <- read.csv('Heart_health.csv')
head(heart_health)
dim(heart_health)
summary(heart_health)

#### Data Cleaning


# First, check for NA
pie(table(is.na(heart_health)), col= c(rgb(0,1,0,0.5),rgb(1,0,0,0.5)),
    labels= c("Value", "NA"),
    main= "Pie Chart of Valid Values to NA values") # No NA values in my dataset

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
table(heart_health$bp_cat)

heart_health$bp_cat <- factor(heart_health$bp_cat,levels= c("Normal","Elevated", "Hypertension 1"))
## I drop hypertension 2 and crisis because none in dataset

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

#BMI and smoking plot

###-------------------------------------------------------------------------------

## Question 2: What is the relationship between Elevated Blood Pressure and smoking?
# Question 2a: Is there a gender factor to this relationship?

# First, let's look at the relationship between smoking and blood pressure. 
# I've divided the dataset between smokers and non-smokers in the data cleaning proccess.

smoker_lab <- c("Nonsmoker", "Smoker")
hh_smoker_tab <- table(heart_health$Smoker)
s_perc <- c()
for (i in c(1:2)) {
  val = hh_smoker_tab[[i]]
  perc = val / dim(heart_health)[1]
  s_perc <- rbind(s_perc, perc)
}
s_perc <- round(s_perc[c(1,2)],2)
s_perc_lab<- paste(smoker_lab, " ", s_perc, "%", sep= "")
pie(hh_smoker_tab, 
    main= "Frequency chart of Smokers in our Dataset",
    labels= s_perc_lab,
    col= c(rgb(1,0,0,0.5), rgb(0,1,0,0.5)),
    radius= 1
    )
## We have roughly the same amount of non-smokers as smokers.
remove(smoker_lab, s_perc, s_perc_lab)

smoke_table <- table(heart_health$bp_cat, heart_health$Smoker)

smoke_bar <- barplot(t(smoke_table),
        beside=T, 
        main= "Blood Pressure Categories by Smoker",
        ylim= c(0,300),
        ylab= "Count",
        xlab= "Blood Pressure Category",
        col= c(rgb(1,0,0,0.4), rgb(0, 1, 0, 0.4))
        )


text(smoke_bar, t(smoke_table)+20, labels= t(smoke_table[c(1,6)]))

legend("topright", 
       c("No", "Yes"), 
       col = c(rgb(1, 0, 0, 0.4), 
               rgb(0, 1, 0, 0.4)), 
       bty= "n",
       cex=1.3,
       lwd = 20)

## Interestingly, we see that Hypertension 1 is way higher in
## Non-smokers than in Smokers. Let's see the BMI range for
## the two categories.

dens_smoker <- density(smoker_hh$bmi, bw= 0.5)
dens_nonsmoker <- density(nonsmoker_hh$bmi, bw= 0.5)

plot(dens_smoker, col=rgb(0, 0, 1, 0.5), lwd= 4,
     main= "Distribution of BMI by Smoker",
     xlab= "BMI",
     ylab= "Density",
     ylim= c(0,0.7))
lines(dens_nonsmoker, col=rgb(1, 0, 0, 0.5),lty= 3, lwd= 4)


legend("topleft", c("NonSmoker", "Smoker"), 
       col=c(rgb(1,0,0,0.25),rgb(0,0,1,0.25), rgb(1,0,0,0.5)), lwd=20)

## From the graph, we see that Smoking and Non-Smoking have
## Similar BMI distributions. Smokers have slightly higher
## BMI measurements, but this does not explain why the
## Non-smokers in our dataset have higher rates of Hypertension.

gender_lab <- c("Female", "Male")
sgen_tab <- table(smoker_hh$Gender)
nsgen_tab <- table(nonsmoker_hh$Gender)

sgen_perc <- c()
for (i in c(1:2)) {
  val = sgen_tab[[i]]
  perc = val / dim(smoker_hh)[1]
  sgen_perc <- rbind(sgen_perc, perc)
}
sgen_perc <- round(sgen_perc[c(1,2)],2)
sgen_perc_lab<- paste(names(sgen_tab), " ", sgen_perc, "%", sep= "")

nsgen_perc <- c()
for (i in c(1:2)) {
  val = nsgen_tab[[i]]
  perc = val / dim(nonsmoker_hh)[1]
  nsgen_perc <- rbind(nsgen_perc, perc)
}
nsgen_perc <- round(nsgen_perc[c(1,2)],2)
nsgen_perc_lab<- paste(names(nsgen_tab), " ", nsgen_perc, "%", sep= "")


par(mfrow= c(1,2))
pie(sgen_tab, 
    labels= sgen_perc_lab, 
    radius= 1,
    col= c(rgb(1,.702,.878, 1), rgb(.722,.796,1, 1)),
    main= "Gender Distribution of Smokers"
    )

pie(nsgen_tab, 
    labels= nsgen_perc_lab, 
    radius= 1,
    col= c(rgb(1,.702,.878, 1), rgb(.722,.796,1, 1)),
    main= "Gender Distribution of Non Smokers"
)

remove(gender_lab, sgen_tab,nsgen_tab, 
       sgen_perc, sgen_perc_lab, 
       nsgen_perc, nsgen_perc_lab)

## From our pie chart, we see that our Smoker data
## has more Male participants and vice versa for Nonsmokers.
## This raises the question: do Females have higher rates of
## Hypertension than Males?

## Note: It is still worth mentioning, our smoker table shows
## more elevated Blood Pressure than non-smokers. 

## Let's take a look at gender.
par(mfrow= c(1,1))
barplot(table(female_hh$bp_cat),
        main= "Blood Pressure by Gender",
        ylim= c(0,300),
        ylab= "Frequency",
        xlab= "Blood Pressure Category",
        col= rgb(1,0,0,0.25)
)

barplot(table(male_hh$bp_cat),
        col= rgb(0,0,1,0.25),
        add= T
)

legend("top", c("Female", "Male"), 
       col=c(rgb(1,0,0,0.25),rgb(0,0,1,0.25), rgb(1,0,0,0.5)), lwd=20)


## As we can see, there hypertension is way higher in Males
## than in Females. Let's see what is happening in 
## our smoker datasets.


par(mfrow=c(1,2)
    )

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

# BMI, Smoking, and Gender


bsg_data <- c()
bsg_data <- cbind(female_hh[which(female_hh$Smoker == "No"),]$bmi,
                  female_hh[which(female_hh$Smoker == "Yes"),]$bmi,
                  male_hh[which(male_hh$Smoker == "No"),]$bmi,
                  male_hh[which(male_hh$Smoker == "Yes"),]$bmi
                              )

boxplot(bsg_data,
        names= c("Female", "Female", "Male", "Male"),
        main= "BMI by Gender and Smoking",
        xlab= "Gender",
        ylab= "BMI",
        col= c(rgb(1,0,0,0.5), rgb(0,1,0,0.5)),
        beside= T, at= c(1,1.85,3,3.85))

legend("topleft", 
       c('Nonsmoker', 'Smoker'), 
       fill= c(rgb(1,0,0,0.5), rgb(0,1,0,0.5)),
       inset= 0.025
       )


## From the boxplot, we can see that Gender has a stronger relationship to 
## blood pressure than smoking does-- with males having higher BMI's than
## females. Following, smokers in the female category tend to have higher BMIs
## while males have roughly the same BMI for both smokers and nonsmokers. 

## With the context of BMI having a positive relationship to Blood Pressure,
## my inference that Gender has a positive relationship to Blood Pressure-- 
## most likely due to differing habits between genders-- still holds true.
## The undetermined relationship between smoking and Blood Pressure also still holds true. 
###-------------------------------------------------------------------------------


## Question 3: How does cholesterol affect blood pressure? glucose levels?
# Question 3a: What is boths' the relationship to BMI?

par(mfrow= c(1,1))
orderBMI <- heart_health[order(heart_health$bmi),]

plot(orderBMI$Cholesterol.mg.dL. ~ orderBMI$bmi,
     main= "Cholesterol by BMI",
     xlab= "BMI",
     xlim= c(24, 27),
     ylab= "mg/dL",
     pch= 15,
     col= 'red'
)
chol_reg <- lm(orderBMI$Cholesterol.mg.dL. ~ orderBMI$bmi)
chol_coef <- round(coef(chol_reg))
abline(chol_reg, lty=2, lwd=2, col= "red")
text(x= 24.75, y= 220, 
    paste("y= ", chol_coef[2],"*Cholesterol (mg/dL) + ", 
          chol_coef[1]), col= "red", cex= 1)

## From our graph, we notice that there is a 
## strong positive correlation between BMI and cholesterol,
## with a regression equation of y= 13*Cholesterol(mg/dL) - 126.

plot(orderBMI$Glucose.mg.dL. ~ orderBMI$bmi,
     main= "Glucose by BMI",
     xlab= "BMI",
     xlim= c(24, 27),
     ylab= "mg/dL",
     pch= 15,
     col= 'blue'
)
glu_reg <- lm(orderBMI$Glucose.mg.dL.~orderBMI$bmi)
glu_coef <- round(coef(glu_reg),2)
abline(glu_reg, lty=2, lwd= 2, col= "blue")
text(x= 24.75, y= 95, 
     paste("y= ", glu_coef[2],"*Glucose (mg/dL) + ", 
           glu_coef[1]), col= "blue", cex= 1)


### Looking at them on one graph
plot(orderBMI$Cholesterol.mg.dL. ~ orderBMI$bmi,
     main= "Cholesterol and Glucose by BMI",
     xlab= "BMI",
     xlim= c(24, 27),
     ylab= "mg/dL",
     ylim= c(0,300),
     pch= 15,
     col= 'red'
)
abline(chol_reg, lty=2, lwd=2, col= "red")
text(x= 24.75, y= 220, 
     paste("y= ", chol_coef[2],"*Cholesterol (mg/dL) + ", 
           chol_coef[1]), col= "red", cex= 1)


points(orderBMI$Glucose.mg.dL. ~ orderBMI$bmi,,
     pch= 15,
     col= 'blue'
)
abline(glu_reg, lty=2, lwd= 2, col= "blue")
text(x= 24.75, y= 100, 
     paste("y= ", glu_coef[2],"*Glucose (mg/dL) + ", 
           glu_coef[1]), col= "blue", cex= 1)

remove(orderBMI, chol_reg, 
       chol_coef, glu_reg, 
       glu_coef)

## From our graph, we notice that there is a 
## slight positive correlation between BMI and glucose levels,
## with a regression equation of y= 3.86*Glucose(mg/dL) - 7.31.

# Cholesterol and BMI

boxplot(heart_health$Cholesterol.mg.dL. ~ heart_health$bp_cat,
        xlab= "Blood Pressure Category",
        ylab= "Cholesterol (mg/dL)",
        main= "Cholesterol by Blood Pressure Category",
        col= c('yellow', 'orange', 'red')
        )

## From the box plot, we can see that higher cholesterol levels 
## have a positive relationship to hypertension, which is consistent
## with BMI's relationship to Cholesterol and Blood Pressure

# Glucose and BMI

boxplot(heart_health$Glucose.mg.dL. ~ heart_health$bp_cat,
        xlab= "Blood Pressure Category",
        ylab= "Glucose (mg/dL)",
        main= "Glucose by Blood Pressure Category",
        col= c('yellow', 'orange', 'red')
)

summary(heart_health[which(heart_health$bp_cat == "Normal"),]$Glucose.mg.dL)

## Similarly, elevated blood pressure and hypertension 1 are consistent
## with high glucose levels. However, there isn't as strong of a 
## relationship as with Cholesterol. 

##This is noticeable by the lack of separation between 
## glucose levels and the range between elevated blood pressure 
## to hypertension 1.It is also worth noting that glucose levels 
## within the normal blood pressure category are at a wide range to 94. Thus,
## higher blood pressure ratings can be predicted only past Glucose levels
## of 94+.


## Thus, though Glucose has a slightly positive relationship
## to BMI, it is not a good indicator of hypertension. 

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

