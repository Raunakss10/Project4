# 🍽️ Do Healthy Recipes Get Lower Ratings?

### A Data Science Investigation of Recipe Tags, Nutrition, and User Preferences

**Raunak Saluja and Dhruv Mittal · UC San Diego**

🔗 [View on GitHub](https://github.com/Raunakss10/Project4)

---

## 💡 TL;DR

* Healthy-tagged recipes were **slightly lower rated on average**
* The difference was **not statistically significant (p ≈ 0.065)**
* Missingness in `rating` depends on cooking time and calories (**MAR**)
* Baseline model performed poorly (**R² ≈ 0**)
* Final model (Random Forest) achieved **Test R² ≈ 0.4008**
* Strongest predictors: **nutritional density + recipe efficiency**
* No significant fairness difference between groups

---

## 📖 Introduction

This project investigates whether recipes labeled as **healthy** receive lower ratings than other recipes on Food.com.

### Research Question

> Do recipes tagged as healthy receive lower average ratings than other recipes?

We approach this through:

1. **Inference** — testing rating differences
2. **Prediction** — modeling recipe ratings

---

## 📊 Datasets

### `RAW_recipes.csv`

* name, id, minutes, submitted
* tags, nutrition
* n_steps, ingredients, n_ingredients

### `interactions.csv`

* user_id, recipe_id
* date, rating, review

---

## 🧹 Data Cleaning

* Merged datasets on recipe ID
* Replaced `rating = 0` with `NaN`
* Converted dates to datetime
* Computed `average_rating`
* Expanded nutrition into:

  * calories, fat, sugar, sodium, protein

### Feature Engineering

* `log_minutes`, `log_calories`
* Nutritional ratios
* Recipe efficiency features

---

## 🥗 Defining Healthy Recipes

We created `is_healthy_tag` using tags like:

* healthy
* low-fat
* low-carb
* low-calorie
* high-protein
* low-sugar

---

## 📈 Exploratory Data Analysis

### Calories Distribution

![Calories Distribution](calories_distribution.png)

### Cooking Time Distribution

![Cooking Time Distribution](cooking_time_distribution.png)

### Key Insight

* Both variables were **right-skewed**
* Log transformation improved interpretability

---

## ❗ Missingness Analysis

### Test 1: Rating vs Minutes

* Observed statistic: **11.51**
* p-value: **0.0**

![Missingness vs Minutes](missingness_minutes.png)

### Test 2: Rating vs Calories

* Observed statistic: **67.98**
* p-value: **0.0**

![Missingness vs Calories](missingness_calories.png)

### Conclusion

* Not MCAR
* Likely **MAR (Missing At Random)**

---

## 🧪 Hypothesis Testing

* Observed difference: **-0.00336**
* p-value: **0.0653**

![Permutation Distribution](permutation_distribution.png)

### Result

❌ Fail to reject null
→ No significant difference in ratings

---

## 🤖 Prediction Problem

* Target: `average_rating`
* Type: Regression
* Metric: **R²**

---

## ⚙️ Models

### Baseline Model

* Features: time, steps, ingredients, calories
* Result: **R² ≈ 0**

---

### 🌲 Final Model (Random Forest)

#### Performance

* Train R²: **0.4236**
* Test R²: **0.4008**

#### Feature Importance

![Feature Importance](feature_importance.png)

### Key Drivers

* Nutritional density
* Recipe efficiency

---

## ⚖️ Fairness Analysis

* MAE (healthy): **0.1694**
* MAE (non-healthy): **0.1712**
* Difference: **-0.0018**
* p-value: **0.4235**

![Fairness Analysis](fairness_mae.png)

### Result

✅ No fairness issue detected

---

## 📌 Key Takeaways

* Healthy recipes are **not significantly lower rated**
* Ratings depend more on:

  * nutrition
  * efficiency
* Feature engineering was critical
* Model generalizes well

---

## 🚧 Limitations

* “Healthy” defined via tags
* No NLP on reviews
* No user personalization

---

## 🔮 Future Work

* Build a nutrition-based health score
* Use review text (NLP)
* Model user preferences

---

## 👨‍💻 Authors

**Raunak Saluja**
**Dhruv Mittal**
UC San Diego — Data Science
