import os
import ast
import cv2
from imgaug import augmenters as iaa


# Function to read classes with less than 5 samples from input text file
def read_classes_with_few_samples(input_file):
    classes_with_few_samples = {}
    with open(input_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            class_info, count = line.strip().split(':')
            class_tuple = ast.literal_eval(class_info.strip())
            # Remove the trailing comma before converting to integer
            count = count.strip().rstrip(',')
            classes_with_few_samples[class_tuple] = int(count)
    return classes_with_few_samples


# Function to apply data augmentation to classes with less than 5 samples
def augment_classes_with_few_samples(main_dataset_folder, classes_with_few_samples):
    for class_info, count in classes_with_few_samples.items():
        make, model, year = class_info
        
        # Path to the folder containing class samples
        class_folder = os.path.join(main_dataset_folder, make, model, year)
        
        # Check if class folder exists
        if os.path.exists(class_folder):
            # Get list of color folders inside the year folder
            color_folders = os.listdir(class_folder)
            for color_folder in color_folders:
                # Path to the color folder
                color_folder_path = os.path.join(class_folder, color_folder)
                
                # Check if color folder exists
                if os.path.isdir(color_folder_path):
                    # Get list of sample files in the color folder
                    sample_files = os.listdir(color_folder_path)
                    
                    # Apply data augmentation if there are less than 5 samples
                    if len(sample_files) < 5:
                        # Load images and apply data augmentation
                        for i in range(5 - len(sample_files)):  # Generate additional samples
                            for sample_file in sample_files:
                                # Read the original image
                                image_path = os.path.join(color_folder_path, sample_file)
                                image = cv2.imread(image_path)
                                
                                # Apply data augmentation techniques (you can customize this)
                                seq = iaa.Sequential([
                                    iaa.Fliplr(0.5),  # horizontally flip 50% of images
                                    iaa.GaussianBlur(sigma=(0, 3.0))  # blur images with a sigma of 0 to 3.0
                                ])
                                image_aug = seq.augment_image(image)  # Apply augmentation
                                
                                # Save the augmented image
                                new_image_path = os.path.join(color_folder_path, f"{os.path.splitext(sample_file)[0]}_aug_{i}.jpg")
                                cv2.imwrite(new_image_path, image_aug)
                                print(f"Augmented image saved: {new_image_path}")

# Example usage:
input_file = 'output_file.txt'  # Input text file containing classes with less than 5 samples
main_dataset_folder = 'resized_DVM'  # Main dataset folder
classes_with_few_samples = read_classes_with_few_samples(input_file)
augment_classes_with_few_samples(main_dataset_folder, classes_with_few_samples)
