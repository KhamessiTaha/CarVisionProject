import os
import shutil
import pandas as pd
from sklearn.model_selection import train_test_split

def remove_single_sample_classes(df):
    # Count the number of samples for each class
    class_counts = df.groupby(['Make', 'Model', 'Year']).size()
    # Get classes with more than one sample
    valid_classes = class_counts[class_counts > 1].index
    # Filter the DataFrame to keep only samples from valid classes
    filtered_df = df[df.set_index(['Make', 'Model', 'Year']).index.isin(valid_classes)]
    return filtered_df

def random_split_with_class_check(df, train_size, val_size, test_size, random_state):
    # Shuffle the DataFrame
    df_shuffled = df.sample(frac=1, random_state=random_state)
    
    # Initialize splits
    train_df = pd.DataFrame(columns=df.columns)
    val_df = pd.DataFrame(columns=df.columns)
    test_df = pd.DataFrame(columns=df.columns)
    
    # Iterate through each class
    classes = df_shuffled[['Make', 'Model', 'Year']].drop_duplicates()
    for _, class_info in classes.iterrows():
        # Get samples for the current class
        class_samples = df_shuffled[(df_shuffled['Make'] == class_info['Make']) & 
                                     (df_shuffled['Model'] == class_info['Model']) & 
                                     (df_shuffled['Year'] == class_info['Year'])]
        
        # Calculate the number of samples for each split
        n_samples = len(class_samples)
        n_train = int(n_samples * train_size)
        n_val = int(n_samples * val_size)
        n_test = n_samples - n_train - n_val
        
        # Split samples for the current class
        train_samples = class_samples.iloc[:n_train]
        val_samples = class_samples.iloc[n_train:n_train+n_val]
        test_samples = class_samples.iloc[n_train+n_val:]
        
        # Add samples to respective splits
        train_df = pd.concat([train_df, train_samples])
        val_df = pd.concat([val_df, val_samples])
        test_df = pd.concat([test_df, test_samples])
    
    return train_df, val_df, test_df

def stratified_split(dataset_folder, csv_filename, output_folder, train_ratio=0.7, val_ratio=0.15, test_ratio=0.15, random_state=42):
    # Load the CSV file containing image labels
    df = pd.read_csv(csv_filename)
    
    # Remove classes with only one sample
    df = remove_single_sample_classes(df)
    
    # Perform random split while ensuring each split contains at least one sample from each class
    train_df, val_df, test_df = random_split_with_class_check(df, train_ratio, val_ratio, test_ratio, random_state)
    
    # Create output folders for training, validation, and testing sets
    train_folder = os.path.join(output_folder, 'train')
    val_folder = os.path.join(output_folder, 'val')
    test_folder = os.path.join(output_folder, 'test')
    os.makedirs(train_folder, exist_ok=True)
    os.makedirs(val_folder, exist_ok=True)
    os.makedirs(test_folder, exist_ok=True)
    
    # Copy images to respective folders based on the split
    for df_split, folder in [(train_df, train_folder), (val_df, val_folder), (test_df, test_folder)]:
        for _, row in df_split.iterrows():
            image_filename = row['Image']
            source_path = os.path.join(dataset_folder, image_filename)
            destination_path = os.path.join(folder, image_filename)
            shutil.copy2(source_path, destination_path)
    
    # Save split CSV files
    train_df.to_csv(os.path.join(output_folder, 'train_labels.csv'), index=False)
    val_df.to_csv(os.path.join(output_folder, 'val_labels.csv'), index=False)
    test_df.to_csv(os.path.join(output_folder, 'test_labels.csv'), index=False)

# Define paths
dataset_folder = 'dataset_copy_with_augmentation'  # Dataset folder containing images
csv_filename = 'labels_final.csv'  # CSV file containing image labels
output_folder = 'random_dataset_split'  # Output folder for split dataset

# Perform random split with class check and create new CSV files and folders
stratified_split(dataset_folder, csv_filename, output_folder)

print("Random dataset splitting complete!")
