import os
import csv
import shutil


def process_dataset(root_dir, output_dir, csv_filename):
    with open(csv_filename, 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['Image', 'Make', 'Model', 'Year'])

        image_count = 0  

        for make_dir in os.listdir(root_dir):
            make_path = os.path.join(root_dir, make_dir)
            if os.path.isdir(make_path):
                for model_dir in os.listdir(make_path):
                    model_path = os.path.join(make_path, model_dir)
                    if os.path.isdir(model_path):
                        for year_dir in os.listdir(model_path):
                            year_path = os.path.join(model_path, year_dir)
                            if os.path.isdir(year_path):
                                for color_dir in os.listdir(year_path):
                                    color_path = os.path.join(year_path, color_dir)
                                    if os.path.isdir(color_path):
                                        for image_file in os.listdir(color_path):
                                            image_path = os.path.join(color_path, image_file)
                                            if os.path.isfile(image_path):
                                                
                                                new_filename = f"{image_count}.jpg"
                                                output_image_path = os.path.join(output_dir, new_filename)
                                                shutil.copy2(image_path, output_image_path)
                                                
                                                
                                                make, model, year = make_dir, model_dir, year_dir
                                                
                                        
                                                csv_writer.writerow([new_filename, make, model, year])
                                                
                                                image_count += 1


root_directory = 'resized_DVM'
output_directory = 'dataset_copy'
csv_filename = 'labels_final.csv'


os.makedirs(output_directory, exist_ok=True)


process_dataset(root_directory, output_directory, csv_filename)

print("Dataset transformation complete!")
