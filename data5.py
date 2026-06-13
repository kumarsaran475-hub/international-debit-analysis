import pandas as pd
data5=pd.read_csv("C:/Users/SARAN K/Downloads/IDS_ALLCountries_Data.csv",encoding='latin1')
print(data5.shape)
print(data5.info())
print(data5.head())
print(data5.tail())
print(data5.columns)
print(data5.dtypes)
print("\n null values in data5:")
print(data5.isnull().sum())
print("\n print duplicate values in data5:")
print(data5.drop_duplicates(inplace=True))
print("\n print duplicate values in data5:")
print(data5.duplicated().sum())

for col in ['Country Name','Country Code','Counterpart-Area Name','Counterpart-Area Code','Series Name','Series Code']:
    data5[col] = data5[col].fillna('Unknown')

data5 = data5.fillna(0)
print(data5.isnull().sum())

data5_long = data5.melt(
    id_vars=['Country Name','Country Code','Counterpart-Area Name','Counterpart-Area Code','Series Name','Series Code'],
    var_name='Year',
    value_name='Value'
)

country_debt = data5_long.groupby('Country Name')['Value'].sum().reset_index()
country_debt = country_debt.sort_values(by='Value', ascending=False)

print(country_debt.head(10)) 

top_countries = country_debt.head()
bottom_countries = country_debt.tail()
print("Top 5 Countries:\n", top_countries)
print("Bottom 5 Countries:\n", bottom_countries)

indicator_debt = data5_long.groupby('Series Name')['Value'].mean().reset_index()
indicator_debt=indicator_debt.sort_values(by='Value',ascending=False)

print(indicator_debt.head(10)) 

correlation = data5_long.pivot_table(values='Value', index='Year', columns='Series Name').corr()
print(correlation)

yearly_trend = data5_long.groupby('Year')['Value'].sum().reset_index()
print(yearly_trend)


summary_stats = data5_long.groupby('Country Name')['Value'].describe()
print(summary_stats)

comparison = data5_long.pivot_table(values='Value', index='Country Name', columns='Series Name', aggfunc='mean')
print(comparison.head())

import matplotlib.pyplot as plt


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


