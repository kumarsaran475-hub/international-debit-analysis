import pandas as pd

data1 = pd.read_csv("C:/Users/SARAN K/Downloads/Country-Series - Metadata.csv", encoding="latin1")
print(data1.shape)
print(data1.info())
print(data1.head())
print(data1.tail())
print(data1.isnull().sum())
print(data1.duplicated().sum())
print(data1.columns)
print(data1.dtypes)

data1['Country_Name'] = data1['Country Code'].str.extract(r'^(.*)\s\(')
data1['ISO_Code'] = data1['Country Code'].str.extract(r'\((.*?)\)')
print(data1.head())
print(data1.shape)



