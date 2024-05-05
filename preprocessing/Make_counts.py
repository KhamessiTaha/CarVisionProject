import pandas as pd

def count_samples_by_make(label_file_path):
    # Read the CSV file containing label information
    labels_df = pd.read_csv(label_file_path)
    
    # Count occurrences of each make
    make_counts = labels_df['Make'].value_counts()
    
    return make_counts

def write_make_counts_to_file(make_counts, output_file_path):
    # Write make counts to a text file
    with open(output_file_path, 'w') as f:
        for make, count in make_counts.items():
            f.write(f"{make}: {count}\n")

if __name__ == "__main__":
    label_file_path = "filtered.csv"
    output_file_path = "make_counts_after_filtering.txt"
    
    make_counts = count_samples_by_make(label_file_path)
    write_make_counts_to_file(make_counts, output_file_path)
    print("Make counts written to", output_file_path)
