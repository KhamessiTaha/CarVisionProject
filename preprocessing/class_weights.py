import numpy as np
import pandas as pd

def calculate_class_weights(labels):
    unique_classes, class_counts = np.unique(labels, return_counts=True)
    total_samples = np.sum(class_counts)
    class_weights = {}
    for cls, count in zip(unique_classes, class_counts):
        class_weights[cls] = total_samples / (len(unique_classes) * count)
    return class_weights


data = pd.read_csv('labels_final.csv')  


labels = data[['Make', 'Model', 'Year']].astype(str).agg('-'.join, axis=1).values


class_weights = calculate_class_weights(labels)
print("Class Weights:", class_weights)


average_class_weight = np.mean(list(class_weights.values()))
print("Average Class Weight:", average_class_weight)
