import os
import ast
import cv2
from imgaug import augmenters as iaa


def read_classes_with_few_samples(input_file):
    classes_with_few_samples = {}
    with open(input_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            class_info, count = line.strip().split(':')
            class_tuple = ast.literal_eval(class_info.strip())
            
            count = count.strip().rstrip(',')
            classes_with_few_samples[class_tuple] = int(count)
    return classes_with_few_samples



def augment_classes_with_few_samples(main_dataset_folder, classes_with_few_samples):
    for class_info, count in classes_with_few_samples.items():
        make, model, year = class_info
        

        class_folder = os.path.join(main_dataset_folder, make, model, year)
        

        if os.path.exists(class_folder):

            color_folders = os.listdir(class_folder)
            for color_folder in color_folders:
               
                color_folder_path = os.path.join(class_folder, color_folder)
                
                
                if os.path.isdir(color_folder_path):
                  
                    sample_files = os.listdir(color_folder_path)
                    
                    
                    if len(sample_files) < 40:
                        
                        for i in range(40 - len(sample_files)):  
                            for sample_file in sample_files:
                                
                                image_path = os.path.join(color_folder_path, sample_file)
                                image = cv2.imread(image_path)
                                
                                
                                seq = iaa.Sequential([
    iaa.Fliplr(0.5),  
    iaa.GaussianBlur(sigma=(0, 3.0)),
    iaa.Affine(rotate=(-45, 45)),  
    iaa.AdditiveGaussianNoise(scale=(0, 0.1 * 255)),  
    iaa.Multiply((0.5, 1.5), per_channel=0.5),  
    iaa.ContrastNormalization((0.5, 2.0), per_channel=0.5),  
    iaa.Affine(scale=(0.5, 1.5)),  
])

image_aug = seq.augment_image(image)
 
                                
                                
                                new_image_path = os.path.join(color_folder_path, f"{os.path.splitext(sample_file)[0]}_aug_{i}.jpg")
                                cv2.imwrite(new_image_path, image_aug)
                                print(f"Augmented image saved: {new_image_path}")


input_file = 'output_file.txt'  
main_dataset_folder = 'resized_DVM' 
classes_with_few_samples = read_classes_with_few_samples(input_file)
augment_classes_with_few_samples(main_dataset_folder, classes_with_few_samples)
