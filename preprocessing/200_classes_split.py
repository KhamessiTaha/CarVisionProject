import pandas as pd

csv_file_path = "labels.csv"
output_file_path = "batch_one.csv"

df_labels = pd.read_csv(csv_file_path)


model_counts = df_labels.groupby(['Make', 'Model', 'Year']).size()
sorted_models = model_counts.sort_values(ascending=False)

top_200_models = sorted_models.head(200)

with open(output_file_path, 'w') as f:
    for index, value in top_200_models.items():
        f.write(f"{index}\n")
