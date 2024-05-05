import os
import pandas as pd
import zipfile

def split_dataset_by_make(labels_csv, images_folder, output_folder, train_ratio=0.8):
    # Load the CSV file
    labels_df = pd.read_csv(labels_csv)
    
    # Identify unique makes
    unique_makes = labels_df['Make'].unique()
    
    # Iterate over unique makes
    for make in unique_makes:
        # Filter dataset for the current make
        make_df = labels_df[labels_df['Make'] == make]
        
        # Split dataset into training and testing
        train_df = make_df.sample(frac=train_ratio, random_state=42)
        test_df = make_df.drop(train_df.index)
        
        # Create output folder for the current make
        make_output_folder = os.path.join(output_folder, make)
        os.makedirs(make_output_folder, exist_ok=True)
        
        # Save training and testing CSV files
        train_csv_path = os.path.join(make_output_folder, f"{make}_train.csv")
        test_csv_path = os.path.join(make_output_folder, f"{make}_test.csv")
        
        train_df.to_csv(train_csv_path, index=False)
        test_df.to_csv(test_csv_path, index=False)
        
        # Create and save zip files for training and testing data
        with zipfile.ZipFile(os.path.join(make_output_folder, f"{make}_train.zip"), 'w') as train_zip:
            for index, row in train_df.iterrows():
                image_path = os.path.join(images_folder, row['Image'])
                train_zip.write(image_path, arcname=row['Image'])
        
        with zipfile.ZipFile(os.path.join(make_output_folder, f"{make}_test.zip"), 'w') as test_zip:
            for index, row in test_df.iterrows():
                image_path = os.path.join(images_folder, row['Image'])
                test_zip.write(image_path, arcname=row['Image'])

if __name__ == "__main__":
    labels_csv = "filtered.csv"
    images_folder = "data"
    output_folder = "New Dataset"
    
    split_dataset_by_make(labels_csv, images_folder, output_folder)
