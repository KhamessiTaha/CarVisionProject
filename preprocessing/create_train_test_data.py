import os
import shutil
import pandas as pd

def create_train_test_data(top_200_classes_file, original_csv_file, image_data_folder, output_folder):
    
    with open(top_200_classes_file, 'r') as f:
        top_200_classes_list = [eval(line.strip()) for line in f.readlines()]

    
    df_original = pd.read_csv(original_csv_file)

  
    df_selected = df_original[df_original.apply(lambda x: (x['Make'], x['Model'], x['Year']) in top_200_classes_list, axis=1)]

    
    grouped = df_selected.groupby(['Make', 'Model', 'Year'])

    
    sampled_data = pd.DataFrame()

   
    for _, group in grouped:
        sampled_data = pd.concat([sampled_data, group.sample(n=200, replace=True, random_state=42)])

    
    total_samples = len(sampled_data)
    train_samples = int(total_samples * 0.8)
    test_samples = total_samples - train_samples

    
    train_folder = os.path.join(output_folder, "train")
    test_folder = os.path.join(output_folder, "test")
    os.makedirs(train_folder, exist_ok=True)
    os.makedirs(test_folder, exist_ok=True)

    
    train_data = sampled_data.sample(n=train_samples, random_state=42)
    test_data = sampled_data.drop(train_data.index)

    
    train_image_folder = os.path.join(train_folder, "images")
    os.makedirs(train_image_folder, exist_ok=True)
    for _, row in train_data.iterrows():
        image_file_path = os.path.join(image_data_folder, row['Image'])
        shutil.copy(image_file_path, train_image_folder)

    
    test_image_folder = os.path.join(test_folder, "images")
    os.makedirs(test_image_folder, exist_ok=True)
    for _, row in test_data.iterrows():
        image_file_path = os.path.join(image_data_folder, row['Image'])
        shutil.copy(image_file_path, test_image_folder)

    
    train_labels_file = os.path.join(train_folder, "train_labels.csv")
    test_labels_file = os.path.join(test_folder, "test_labels.csv")
    train_data.to_csv(train_labels_file, index=False)
    test_data.to_csv(test_labels_file, index=False)

   
    shutil.make_archive(train_folder, 'zip', train_folder)
    shutil.make_archive(test_folder, 'zip', test_folder)

    print("Train and test data creation completed.")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Split data into train and test sets.")
    parser.add_argument("--top_200_classes_file", required=True, help="Path to the file containing the top 200 most populated classes.")
    parser.add_argument("--original_csv_file", required=True, help="Path to the CSV file containing all labels for images.")
    parser.add_argument("--image_data_folder", required=True, help="Path to the folder containing all images.")
    parser.add_argument("--output_folder", required=True, help="Path to the output folder where train and test data will be saved.")

    args = parser.parse_args()

    
    create_train_test_data(args.top_200_classes_file, args.original_csv_file, args.image_data_folder, args.output_folder)
