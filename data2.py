import pandas as pd
data2=pd.read_csv("C:/Users/SARAN K/Downloads/IDS_CountryMetaData.csv",encoding="latin1")
print(data2.shape)
print(data2.info())
print("data2 head:")
print(data2.head())
print("data2 tail:")
print(data2.tail())
print(data2.columns)
print(data2.dtypes)
print(data2.isnull().sum())
print("DUPLICATES IN SAMPLE")
print(data2.duplicated().sum())
print(data2.drop_duplicates(inplace=True))

for col in data2.select_dtypes(include=['float64', 'int64']).columns:
    median_val = data2[col].median()
    data2[col] = data2[col].fillna(median_val)

for col in data2.select_dtypes(include=['object', 'string']).columns:
    if not data2[col].mode().empty:
        mode_val = data2[col].mode()[0]
        data2[col] = data2[col].fillna(mode_val)

print('\nMissing values in data2 after cleaning:')
print(data2.isnull().sum())
print('\nDuplicates in data2 after cleaning:')
print(data2.duplicated().sum())
print('\nInfo of data2 after cleaning:')
data2.info()
selected_columns =[
    'Code',
    'Long Name',
    'Short Name',
    'Region',
    'Income Group',
    'Lending category',
    'External debt Reporting status',
    'Currency Unit',
    'Latest population census',
    'Latest household survey',
    'Latest agricultural census',
    'Latest industrial data',
    'Latest trade data',
    'Latest water withdrawal data'
]
filtered = data2[selected_columns].copy()
print(filtered.head())

print(filtered.isnull().sum())

for col in filtered.select_dtypes(include=['float64', 'int64']).columns:
    median_val = filtered[col].median()
    filtered[col] = filtered[col].fillna(median_val)

for col in filtered.select_dtypes(include=['object', 'string']).columns:
    if not filtered[col].mode().empty:
        mode_val = filtered[col].mode()[0]
        filtered[col] = filtered[col].fillna(mode_val)

print(filtered.isnull().sum())

if 'Region' in filtered.columns:
    filtered['Region'] = filtered['Region'].str.title()

if 'Income Group' in filtered.columns:
    filtered['Income Group'] = filtered['Income Group'].str.title()

print("\nData types after cleaning:")
print(filtered.dtypes)

print("\nPreview of cleaned data:")
print(filtered.head())

income_counts = filtered['Income Group'].value_counts()
print(income_counts)

lending_counts=filtered['Lending category'].value_counts()
print(lending_counts)

Report_status=filtered['External debt Reporting status'].value_counts()
print(Report_status)

census_counts=filtered['Latest population census'].value_counts()
print(census_counts)

survey_counts=filtered['Latest household survey'].value_counts()
print(survey_counts)

print(filtered['Latest industrial data'].describe())
print(filtered['Latest trade data'].describe())
print(filtered['Latest water withdrawal data'].describe())

cross_tab = pd.crosstab(filtered['Region'], filtered['Income Group'])
print(cross_tab)

data2.to_csv("C:/Users/SARAN K/OneDrive/Desktop/streamlit/data2.csv", index=False)

print("✅ Cleaned data saved successfully at C:/Users/SARAN K/OneDrive/Desktop/streamlit/data2.csv")


