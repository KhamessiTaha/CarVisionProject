import os
import shutil
import pandas as pd

def filter_by_years(labels_csv, images_folder, output_folder):
    # Create the output folder if it doesn't exist
    os.makedirs(output_folder, exist_ok=True)
    
    # Load the CSV file
    labels_df = pd.read_csv(labels_csv)
    
    # Group by Make and Model
    grouped = labels_df.groupby(['Make', 'Model'])
    
    # Initialize an empty list to store filtered data
    filtered_data = []
    
    # Initialize a set to store image files to delete
    images_to_delete = set()
    
    # Iterate over groups
    for group_name, group_df in grouped:
        # Sort the group by Year in descending order
        group_df_sorted = group_df.sort_values(by='Year', ascending=False)
        
        # Keep only the last 4 years or all available years if less than 4
        last_4_years = group_df_sorted['Year'].unique()[:4]
        
        # Filter the group by the last 4 years
        filtered_group_df = group_df_sorted[group_df_sorted['Year'].isin(last_4_years)]
        
        # Append filtered group to the filtered data list
        filtered_data.append(filtered_group_df)
        
        # Collect image files to delete
        for index, row in group_df.iterrows():
            image_path = os.path.join(images_folder, row['Image'])
            if not row['Year'] in last_4_years and os.path.exists(image_path):
                images_to_delete.add(image_path)
    
    # Concatenate all filtered groups into a single DataFrame
    filtered_labels_df = pd.concat(filtered_data)
    
    # Save the filtered DataFrame to a new CSV file
    filtered_labels_csv = os.path.join(output_folder, "filtered_labels.csv")
    filtered_labels_df.to_csv(filtered_labels_csv, index=False)
    
    # Create a new folder for the filtered images
    filtered_images_folder = os.path.join(output_folder, "filtered_images")
    os.makedirs(filtered_images_folder, exist_ok=True)
    
    # Copy non-filtered images to the new folder
    for file in os.listdir(images_folder):
        source_path = os.path.join(images_folder, file)
        if source_path not in images_to_delete:
            destination_path = os.path.join(filtered_images_folder, file)
            shutil.copyfile(source_path, destination_path)
    
    # Delete filtered images
    for image_path in images_to_delete:
        os.remove(image_path)
    
    return filtered_labels_csv, filtered_images_folder

if __name__ == "__main__":
    labels_csv = "filtered.csv"
    images_folder = "data"
    output_folder = "filtered_data"
    filtered_labels_csv, filtered_images_folder = filter_by_years(labels_csv, images_folder, output_folder)
    print("Filtered labels saved to:", filtered_labels_csv)
    print("Filtered images saved to:", filtered_images_folder)

