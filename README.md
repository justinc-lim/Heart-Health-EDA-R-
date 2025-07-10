# Heart Health EDA in R by Justin Carlou Lim

This project explores and analyzes the Heart Health Dataset found at the following:
https://www.kaggle.com/datasets/mahad049/heart-health-stats-dataset

Main Question: How does bmi affect risk of hypertension?
* What about by gender?
* What about smoking?

### Table of Contents ###
  1. Data Wrangling
  2. BMI and Hypertension
  3. Smoking, Gender and Hypertension

## Data Wrangling
First, I reworked the dataset so it'd be more usable for my analyses. 
* Changed Smoker and Gender column data from character to factor.
* Separate character variable "Blood.Pressure.mmHg." to systolic and diastolic blood pressure. Then, convert to numeric.
* Separate entries by blood pressure categories as described in American Heart Association chart (attached in images folder).
* Calculate BMI using Height (converted to m) and Weight (kg). Create categories based on the chart from the Center for Disease Control (attached in images). 
* Create separate datasets for Smoker/Nonsmoker and Male/Female.

The cleaning process is documented in the code. 

## BMI and Hypertension
Next, I decided to look at the relationship between BMI and Hypertension using the BMI ranges created from the data wrangling process.

In our dataset, I decided to omit the variables "Hypertension 2" and "Hypertension Crisis" because no values fell under these categories. From the chart, we see that the the peak density for those with higher blood pressure readings increases as BMI increases. Thus, we can work with the assumption that there is a positive correlation between BMI and high blood pressure. 

## Smoking, Gender, and Hypertension
