import pandas as pd
data3=pd.read_csv("C:/Users/SARAN K/Downloads/IDS_SeriesMetaData.csv",encoding='latin1')
print(data3.shape)
print(data3.head())
print(data3.tail())
print(data3.info())
print(data3.columns)
print(data3.dtypes)
print("\n null values in data3:")
print(data3.isnull().sum())
print("\n print duplicate values in data3:")
print(data3.duplicated().sum())
Data3=data3.drop(['License Type','Limitations and exceptions','General comments' ],axis=1)
print(Data3.isnull().sum())
for col in Data3.select_dtypes(include='string').columns:
    Data3[col] = Data3[col].fillna('unknown')
print(Data3.isnull().sum())
print(Data3.drop_duplicates(inplace=True))
print(Data3.duplicated().sum())

for col in Data3.select_dtypes(include='object').columns:
    if Data3[col].str.isnumeric().all():
        Data3[col] = pd.to_numeric(Data3[col], errors='coerce')
for col in ['Indicator Name','Source','Topic','Dataset']:
    if col in Data3.columns:
        Data3[col] = Data3[col].str.strip().str.title()
print(Data3['Periodicity'].unique())

