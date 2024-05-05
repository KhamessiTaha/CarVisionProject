import pandas as pd
import matplotlib.pyplot as plt

# Read the dataset
df = pd.read_csv('labels.csv')

# Count the number of images per make (brand)
make_counts = df['Make'].value_counts()
num_classes = df['Model'].nunique()


print("Number of unique classes (models) in the dataset:", num_classes)
# Plot the graph
plt.figure(figsize=(10, 6))
make_counts.plot(kind='bar')
plt.title('Number of Images per Car Make (Brand)')
plt.xlabel('Car Make (Brand)')
plt.ylabel('Number of Images')
plt.xticks(rotation=90)  # Rotates x-axis labels to be vertical
plt.tight_layout()
plt.show()
