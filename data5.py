import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np


data5 = pd.read_csv("C:/Users/SARAN K/Downloads/IDS_ALLCountries_Data.csv", encoding='latin1')

print("Shape:", data5.shape)
print(data5.info())
print(data5.head())
print(data5.tail())
print("Columns:", data5.columns)
print("Data Types:\n", data5.dtypes)

print("\nNull values in data5:\n", data5.isnull().sum())

data5.drop_duplicates(inplace=True)
print("\nDuplicate values count:", data5.duplicated().sum())

num_cols = data5.select_dtypes(include=['float64','int64']).columns
cat_cols = data5.select_dtypes(include=['object','str']).columns

for col in num_cols:
    median_val = data5[col].median()
    data5[col] = data5[col].fillna(median_val)

for col in cat_cols:
    if not data5[col].mode().empty:
        mode_val = data5[col].mode()[0]
        data5[col] = data5[col].fillna(mode_val)

num_summary = pd.DataFrame({
    'Mean': data5[num_cols].mean(),
    'Median': data5[num_cols].median()
})
print("\nNumerical Columns - Mean & Median:\n", num_summary)

cat_summary = pd.DataFrame({
    'Mode': [data5[col].mode()[0] if not data5[col].mode().empty else None for col in cat_cols]
}, index=cat_cols)
print("\nCategorical Columns - Mode:\n", cat_summary)

print("Remaining null values:\n", data5.isnull().sum())



outlier_summary = {}

for col in num_cols:
    Q1 = data5[col].quantile(0.25)
    Q3 = data5[col].quantile(0.75)
    IQR = Q3 - Q1
    
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    

    outliers = data5[(data5[col] < lower_bound) | (data5[col] > upper_bound)][col]
    outlier_summary[col] = {
        "Outlier Count": outliers.shape[0],
        "Lower Bound": lower_bound,
        "Upper Bound": upper_bound
    }
    
    data5[col] = np.where(
        data5[col] < lower_bound, lower_bound,
        np.where(data5[col] > upper_bound, upper_bound, data5[col])
    )

outlier_df = pd.DataFrame(outlier_summary).T
print("\nOutlier Summary for All Numerical Columns:\n", outlier_df)

data5_long = data5.melt(
    id_vars=['Country Name','Country Code','Counterpart-Area Name','Counterpart-Area Code','Series Name','Series Code'],
    value_vars=[col for col in data5.columns if col.isdigit()],  
    var_name='Year',
    value_name='Value'
)

plt.figure(figsize=(8,6))
sns.boxplot(y=data5_long['Value'])
plt.title("Boxplot of Debt Values")
plt.ylabel("Debt Value")
plt.show()


country_debt = data5_long.groupby('Country Name')['Value'].sum().reset_index()
country_debt = country_debt.sort_values(by='Value', ascending=False)
print("\nTop 10 Countries by Debt:\n", country_debt.head(10))

top_countries = country_debt.head()
bottom_countries = country_debt.tail()
print("\nTop 5 Countries:\n", top_countries)
print("\nBottom 5 Countries:\n", bottom_countries)


indicator_debt = data5_long.groupby('Series Name')['Value'].mean().reset_index()
indicator_debt = indicator_debt.sort_values(by='Value', ascending=False)
print("\nTop 10 Indicators by Average Debt:\n", indicator_debt.head(10))

correlation = data5_long.pivot_table(values='Value', index='Year', columns='Series Name').corr()
print("\nCorrelation Matrix:\n", correlation)

yearly_trend = data5_long.groupby('Year')['Value'].sum().reset_index()
print("\nYearly Debt Trend:\n", yearly_trend)

summary_stats = data5_long.groupby('Country Name')['Value'].describe()
print("\nSummary Stats by Country:\n", summary_stats)

comparison = data5_long.pivot_table(values='Value', index='Country Name', columns='Series Name', aggfunc='mean')
print("\nComparison Table:\n", comparison.head())


top10 = country_debt.head(10)
plt.figure(figsize=(10,6))
plt.bar(top10['Country Name'], top10['Value'], color='skyblue')
plt.xticks(rotation=45)
plt.title("Top 10 Countries by Total Debt")
plt.ylabel("Debt Value")
plt.show()

plt.figure(figsize=(10,6))
plt.plot(yearly_trend['Year'], yearly_trend['Value'], marker='o', color='green')
plt.title("Yearly Debt Trend (All Countries)")
plt.xlabel("Year")
plt.ylabel("Total Debt Value")
plt.grid(True)
plt.show()

data5.to_csv("C:/Users/SARAN K/OneDrive/Desktop/streamlit/data5.csv", index=False)

print("✅ Cleaned data saved successfully at C:/Users/SARAN K/OneDrive/Desktop/streamlit/data5.csv")


