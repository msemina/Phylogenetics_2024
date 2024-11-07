#!/bin/bash

# Input file name with accession IDs and species
input_file="gene_accessions.txt"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
  echo "Error: Input file '$input_file' not found."
  exit 1
fi

# Read the first line for the header (gene names), using tab as a delimiter
IFS=$'\t' read -r -a headers < "$input_file"

# Remove the first element of the header array, as it corresponds to the species
gene_names=("${headers[@]:1}")

# Process each line with accession IDs, skipping the header line
tail -n +2 "$input_file" | while IFS=$'\t' read -r -a fields; do
  # The first element is the species, the rest are gene identifiers
  species="${fields[0]}"
  gene_ids=("${fields[@]:1}")

  # Iterate over each gene in the line
  for i in "${!gene_ids[@]}"; do
    gene="${gene_ids[$i]}"
    gene_name="${gene_names[$i]}"

    # Check if the gene has a valid accession ID (starts with XP_)
    if [[ $gene == XP_* ]]; then
      # Download the sequence for the given accession ID
      efetch -db protein -id "$gene" -format fasta > "${gene_name}_${species}.fasta"
      if [[ $? -eq 0 ]]; then
        echo "Downloaded $gene_name for $species with accession $gene"
      else
        echo "Error downloading $gene_name for $species with accession $gene"
      fi
    else
      # If "MappingToKillerW" or "N/A" is specified, skip or mark for manual processing
      echo "Manual processing needed for $gene_name in $species: $gene"
    fi
  done
done

exit 0
