# Load necessary libraries
library(dplyr)
library(ggplot2)
#install.packages("corrplot")
library(corrplot)
#install.packages("caret")
library(caret)
library(tidyverse)
install.packages("gridExtra")
library(gridExtra)
# Import the dataset
 

# Summary of variables
str(My_data)
num_col <- ncol(My_data)
print(paste("Number of Columns:", num_col))
num_row <- nrow(My_data)
print(paste("Number of Rows:", num_row))
summary(My_data)

# Variable types
types <- sapply(My_data, class)
table(types)

# Descriptive Statistics
Descriptive_stat <- summary(My_data)
print(Descriptive_stat)
SD = apply(My_data, 2, sd, na.rm = TRUE)
SD

# Visualize distributions of variables using different plots
# Histogram of Price
Hist_price <- ggplot(My_data, aes(x = price)) +
  geom_histogram(binwidth = 5000, fill = "skyblue", color = "black") +
  labs(title = "Histogram of Price", x = "Price", y = "Frequency")
print(Hist_price)

#Histogram of sqft
Hist_sqft <- ggplot(My_data, aes(x = sqft)) +
  geom_histogram(binwidth = 1000, fill = "purple", color = "black") +
  labs(title = "Histogram of Square Footage",
       x = "Square Footage",
       y = "Frequency")
print(Hist_sqft)



# Scatter plot of Price vs. Sqft
scatter_plt <- ggplot(data, aes(x = sqft, y = price)) +
  geom_point(fill = "green", color = "red") + 
  geom_smooth(method = "loess", se = FALSE, color = "skyblue") +theme_light() +
  labs(title = "Price vs. Sqft", x = "Sqft", y = "Price")
print(scatter_plt)

# Boxplot of Price by Style
box_plot <- ggplot(My_data, aes(x = style, y = price,group=style,color = style)) +
  geom_boxplot( alpha = 0.7) +theme_light() +
  labs(title = "Boxplot of Price by Style", x = "Style", y = "Price") +
  theme(plot.title = element_text(hjust=0.5))
print(box_plot)

# Correlations
correlations_data <- cor(My_data[, sapply(My_data, is.numeric)])

#Print Correlations
print(correlations_data)

#Visualize the Correlations data using a color-coded plot 
corrplot(correlations_data, method = "color")

corrplot(correlations_data, hc.order = TRUE, method = "number")
#Q2
# Probability of having a pool
pool_prob <- sum(data$pool == "1") / nrow(data)
#print the probability of having pool
print(paste("Probability of having a pool:", pool_prob))

#conditional probability that it has a fireplace, given that it has a pool.
#subset of pool
pool_subset <- subset(My_data, pool == "1")
#Calculating the probability that it has a fireplace. When a property has a pool
prob_fireplace_has_pool <- sum(pool_subset$fireplace == "1") / nrow(pool_subset)
print(paste("Conditional probability of having a fireplace given that it has a pool:",prob_fireplace_has_pool))


ggplot(data.frame(Has_Fireplace = c("Yes", "No"), Probability = c(prob_fireplace_has_pool, 1 - prob_fireplace_has_pool)), aes(x = Has_Fireplace, y = Probability)) +
  geom_bar(stat = "identity", fill = "skyblue", width = 0.5) +
  labs(title = "Conditional Probability of Having a Fireplace Given a Pool",
       x = "Has Fireplace",
       y = "Probability")


# Calculating the probability that at least 3 out of 10 houses selected will have a pool.
# Using Binomial distribution
probability_at_least_3 <- sum(dbinom(3:10, size = 10, prob = pool_prob))
print(paste("Probability that at least 3 out of 10 houses selected at random have a pool:",probability_at_least_3))


# Determine the 95% confidence interval for the mean house price in the USA, assuming that the data set contains a random sample of homes in the USA.

confidence_interval_house <- t.test(My_data$price)$conf.int
print(paste("95% Confidence Interval for the mean house price:", confidence_interval_house))


#Q3

#Test the hypothesis that the mean house price (over all house styles) is greater if a house is on the waterfront
#Get waterfront property prices.
waterfront_prices <- My_data$price[My_data$waterfront == 1]
#Get non_waterfront property prices
non_waterfront_prices <- My_data$price[My_data$waterfront == 0]
#Performing two-sample t-test with confidence level is 0.95
t_test <- t.test(waterfront_prices,non_waterfront_prices, data = My_data, alternative = "greater", conf.level = 0.95)

#Ploting boxplot for waterfront vs non-waterfront prices
ggplot(My_data, aes(x=factor(waterfront), y=price, fill=factor(waterfront))) +
  geom_boxplot() +
  labs(x="Waterfront", y="Price", fill="Waterfront") +
  ggtitle("Boxplot of House Prices by Waterfront") +
  theme_bw()

#printing p-value
print(paste("p-value is", t_test$p.value))
#print the output
print(t_test)
#checking if the if the p value is less than 0.05 If it is less than that, then reject the null hypothesis; otherwise, accept the null hypothesis.
if (t_test$p.value < 0.05) {
  print("We reject the null hypothesis. The mean house price is significantly greater for waterfront houses.")
} else {
  print("We do not reject the null hypothesis. The mean house price is not significantly different between waterfront and non-waterfront houses.")
}

#  Create a contingency table showing relative frequencies for "Pool" and "No pool" according to whether a house has or hasn’t got a fireplace
# Create contingency table
Contingency_table <- table(My_data$fireplace, My_data$pool)
# Convert to relative frequencies
Contingency_table_Relative <- prop.table(Contingency_table, margin = 1)
#output
print(Contingency_table_Relative)

# test whether a house having a fireplace is independent of whether it has a pool.
# Perform chi-squared test for independence with a 5% significance level
chisquared_result <- chisq.test(Contingency_table)

#Result
print(chisquared_result)


#Q4  

# Performing simple linear regression
# linear regression with ln(price) as the response variable and ln(sqft) as the predictor variable
simple_li_model <- lm(log(price) ~ log(sqft), data = My_data)
summary(simple_li_model)

# Identify significance of predictor
significance <- ifelse(summary(simple_li_model)$coefficients["log(sqft)", "Pr(>|t|)"] < 0.05, "significant", "not significant")
print(paste("Total area is a", significance, "predictor of house price."))

# Plotting data and fitted model
ggplot(My_data, aes(x = log(sqft), y = log(price))) +
  geom_point() +theme_light() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = "Fitted Model: ln(price) vs. ln(sqft)", x = "ln(sqft)", y = "ln(price)")


My_data$log_price <- log(My_data$price)
My_data$log_sqft <- log(My_data$sqft)

#Fiting a linear regression model
lin_mod <- lm(log_price ~ log_sqft, data = My_data)


residuals1 <- resid(lin_mod)


#Check for normality of errors using Q-Q plot
qqnorm(residuals1, main = "Normal Q-Q Plot of Residuals")
qqline(residuals1, col = "red")



# Plotting residuals
residuals <- residuals(simple_li_model)
ggplot(My_data, aes(x = log(sqft), y = residuals)) +
  geom_point() +theme_light() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Residuals Plot", x = "ln(sqft)", y = "Residuals")

# Comments on the plots:
# The first plot, which uses the fitted linear regression line, displays the relationship between ln (price) and ln (sqft).
# The second visualization shows the residuals,  representing the variances between the observed and fitted values. 
# A reference line for zero residuals is provided in order to evaluate the model's homoscedasticity assumption.
# The assumption is probably satisfied if the residuals are dispersed randomly, with no discernible pattern, around zero.

#Q5

#Perform a multiple linear regression of ln(price) against all the predictor variables

#Convert qualitative variables to factors
data <-My_data %>%
  mutate_if(is.character, as.factor)

# Creating formula for full model
full_model <- log(price) ~ log(sqft) + bedrooms + baths + age + pool + style + fireplace + waterfront + dom
summary(full_model)

# Performing stepwise regression for feature selection
reduced_model <- train(
  full_model,
  data = data,
  method = "lm",
  trControl = trainControl(method = "cv", number = 10, verboseIter = FALSE),
  tuneLength = 1
)
reduced_model
# Comparing the performances of the whole and reduced models using k-fold cross-validation

control <- trainControl(method = "cv", number = 10)
full_model_cv <- train(full_model, data = data, method = "lm", trControl = control)

# Compare model performances using RMSE(Root Mean Square Error)
print(paste("Full Model RMSE:",sqrt(full_model_cv$results$RMSE)))

reduced_model_cv <- train(log(price) ~ log(sqft) + bedrooms + style + fireplace + waterfront + dom, data = data, method = "lm", trControl = control)
# Compare model performances using RMSE(Root Mean Square Error)
print(paste("Reduced Model RMSE:",sqrt(reduced_model_cv$results$RMSE)))




#new  plots


box<-ggplot(data,aes(y=age))+
  geom_boxplot(fill = "red",color = "black")+
  labs(title = "boxplot of age",x="",y="age")+
  theme_classic()
box



ggplot(data, aes(x = factor(pool), fill = factor(fireplace))) +
  geom_bar(position = "stack") +
  labs(title = "Relationship between Pool and Fireplace",
       x = "Has Pool",
       fill = "Has Fireplace")


#use thias one
# Grouped bar plot with counts
ggplot(data, aes(x = factor(pool), fill = factor(fireplace))) +
  geom_bar(position = "dodge") +
  stat_count(geom = "text", aes(label = ..count..), position = position_dodge(width = 0.9), vjust = -0.5) +
  labs(title = "Relationship between Pool and Fireplace",
       x = "Has Pool",
       y = "Count",
       fill = "Has Fireplace")


# Convert 'Age' to a year value (assuming 'Age' represents the year the house was built)
data$Year_Built <- as.numeric(format(Sys.Date(), "%Y")) - data$age

# Calculate average price of houses by year
average_price <- aggregate(price ~ Year_Built, data = data, FUN = mean)

# Line chart showing the average price of houses over the years
ggplot(average_price, aes(x = Year_Built, y = price)) +
  geom_line() +
  labs(title = "Average Price of Houses Over the Years",
       x = "Year Built",
       y = "Average Price")


# Create Histogram with Log Scale
Hist <- ggplot(data, aes(x = price)) +
  geom_histogram(fill = "red", color = "black", binwidth = 0.1, alpha = 0.7) +
  stat_count(aes(label = ..count..), geom = "text", vjust = -0.5, size = 4, color = "black") +
  labs(title = "Histogram of Prices", x = "Price", y = "Frequency") +
  scale_x_log10(labels = scales::comma, breaks = scales::trans_breaks("log10", function(x) 10^x))

# Convert to Plotly object
Hist <- ggplotly(Hist)

# Print the interactive plot
Hist


#use this
ggplot(data, aes(x = factor(pool), fill = factor(pool))) +
  geom_bar() +
  labs(x = "Pool", y = "Count", title = "Count of Properties by Pool") +
  scale_fill_discrete(name = "Pool", labels = c("No Pool", "Pool")) +
  theme_minimal()
