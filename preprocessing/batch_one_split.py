import pandas as pd

# Load your CSV file containing labels (Image, Make, Model, Year)
csv_file_path = "labels.csv"
output_file_path = "batch_one.csv"

df_labels = pd.read_csv(csv_file_path)

# Count the number of samples for each car model
model_counts = df_labels.groupby(['Make', 'Model', 'Year']).size()

# Sort the models based on sample counts in descending order
sorted_models = model_counts.sort_values(ascending=False)

# Select the top 200 most populated classes
top_200_models = sorted_models.head(200)

# Write the output to a text file
with open(output_file_path, 'w') as f:
    for index, value in top_200_models.items():
        f.write(f"{index}\n")
