import os
import pandas as pd

def filter_dataset_and_delete_images(label_file_path, dataset_folder, min_sample_count):
    # Read the CSV label file
    labels_df = pd.read_csv(label_file_path)
    
    # Count occurrences of each make
    make_counts = labels_df['Make'].value_counts()
    
    # Filter out makes with sample counts below min_sample_count
    filtered_makes = make_counts[make_counts >= min_sample_count].index
    
    # Filter the dataset to keep only samples with makes in filtered_makes
    filtered_df = labels_df[labels_df['Make'].isin(filtered_makes)]
    
    # Delete corresponding image files for filtered dataset
    for _, row in labels_df.iterrows():
        image_path = os.path.join(dataset_folder, row['Image'])
        if row['Make'] not in filtered_makes:
            os.remove(image_path)
    
    return filtered_df

if __name__ == "__main__":
    label_file_path = "labels_final.csv"
    dataset_folder = "dataset_copy_with_augmentation"
    min_sample_count = 439
    
    filtered_df = filter_dataset_and_delete_images(label_file_path, dataset_folder, min_sample_count)
    
    # Save the filtered dataset to a new CSV file
    filtered_df.to_csv("filtered.csv", index=False)
    print("Filtered dataset saved to filtered.csv")
