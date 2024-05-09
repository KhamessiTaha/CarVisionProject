import os
import pandas as pd
import matplotlib.pyplot as plt

def count_images_per_class(csv_filename):
    df = pd.read_csv(csv_filename)
    df['Class'] = df.apply(lambda x: (x['Make'], x['Model'], x['Year']), axis=1)
    class_counts = df['Class'].value_counts()
    return class_counts


csv_filename = 'labels_final.csv'


class_counts = count_images_per_class(csv_filename)


plt.figure(figsize=(12, 6))
class_counts.plot(kind='bar', color='darkblue') 
plt.title('Number of Images per Class (Make, Model, Year)')
plt.xlabel('Class (Make, Model, Year)')
plt.ylabel('Number of Images')
plt.xticks([]) 
plt.tight_layout()


plt.savefig('samples_per_class.jpg')


plt.show()

