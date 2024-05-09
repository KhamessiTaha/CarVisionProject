from collections import defaultdict


def read_data_from_csv(csv_file):
    data = []
    with open(csv_file, 'r') as file:
        next(file) 
        for line in file:
            values = line.strip().split(',')
            _, make, model, year, _ = values  
            data.append((make, model, year))
    return data


def count_samples_per_class(data):
    class_counts = defaultdict(int)
    for make, model, year in data:
        class_counts[(make, model, year)] += 1
    return class_counts


csv_file = 'labels.csv'


data = read_data_from_csv(csv_file)


class_counts = count_samples_per_class(data)


threshold = 40 
few_samples_classes = [cls for cls, count in class_counts.items() if count < threshold]
print("Classes with fewer than", threshold, "samples:")
for cls in few_samples_classes:
    print(cls, ":", class_counts[cls], "samples")
