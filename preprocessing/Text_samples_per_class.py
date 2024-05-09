import pandas as pd

def count_samples_per_class(label_csv_path):
    

    df = pd.read_csv(label_csv_path)

   
    class_counts = df.groupby(['Model', 'Brand', 'Year']).size().reset_index(name='Count')

    return class_counts

def save_counts_to_text(class_counts, output_text_path):
    """
    Saves the class counts to a text file.

    Args:
    - class_counts (DataFrame): DataFrame containing counts of samples per class.
    - output_text_path (str): Path to save the output text file.
    """
    class_counts.to_csv(output_text_path, sep='\t', index=False)

if __name__ == "__main__":
 
    label_csv_path = input("filtered.csv")

    
    output_text_path = "class_counts.txt"

   
    class_counts = count_samples_per_class(label_csv_path)

   
    save_counts_to_text(class_counts, output_text_path)

    print("Counts of samples per class saved to:", output_text_path)
