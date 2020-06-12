#!/usr/bin/env python

"""bioentities2json

This script generate json output from taking input as biomart species metadata used in Ensembl update for bioentities collection loading in Solr.

running syntax

python bioentities2json.py -i homo_sapiens.ensgene.tsv

i - Input tsv (tab separated values) is Biomart species metadata file consisting of gene ids as rows and associated gene attributes as columns

Converted json will be printed in STD output
"""

import json
import argparse
import pandas as pd


def get_args():
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('-i', '--input_tsv',
                            required=True,
                            help='A TSV file of gene metadata')
    args = arg_parser.parse_args()
    return args

def read_tsv_file(tsv_file_path):
    tsv_file = pd.read_csv(tsv_file_path, sep='\t', header=0)
    return tsv_file

def join_string(list_string):
    # Join the string based on '_' delimiter
    string = '_'.join(list_string)
    return string

def get_species_name_from_file(file_name):
    species = join_string(file_name.split("/")[-1].split('_')[0:2]).capitalize()
    return species

def get_property_weight(property_name):
    property_names = ['gene_biotype', 'hgnc_symbol', 'uniprot', 'entrezgene']

    if property_name == 'synonym':
        property_weight = 10
        property_id_weight = 0
    elif property_name == 'ensgene':
        property_weight = 15
        property_id_weight = 100
    elif property_name == 'symbol':
        property_weight = 20
        property_id_weight = 90
    elif property_name in property_names:
        property_weight = 0
        property_id_weight = 80
    else:
        property_weight = 0
        property_id_weight = 0

    property_weights = [property_weight, property_id_weight]

    return property_weights

def update_json_fields(geneid, species, property_name, property_value, property_weight, property_weight_id):
    data={}
    data["bioentity_identifier"] = geneid
    data["species"] = species
    data["property_name"] = property_name
    data["property_value"] = property_value
    data["property_weight"] = property_weight
    data["property_name_id_weight"] = property_weight_id

    data=json.dumps(data)
    return data


def main():

    args = get_args()

    tsv_wf = read_tsv_file(args.input_tsv)

    species = get_species_name_from_file(args.input_tsv)

    for index, row in tsv_wf.iterrows():
        for column_name in row.keys():

            ## ignore property names that has no values
            if pd.notnull(row[column_name]):

                # get property weights for attributes given priority while searching in web
                property_weights=get_property_weight(column_name)

                # get property values
                property_value = str(row[column_name])

                # look for property values are more than one
                if len(property_value.split('@@')) > 1:
                    for prop_val in property_value.split('@@'):
                        data = update_json_fields(row['ensgene'], species, column_name, prop_val,
                                                  property_weights[0], property_weights[1])
                        print(data)
                else:
                    # property values
                    data = update_json_fields(row['ensgene'], species, column_name, row[column_name],
                                              property_weights[0], property_weights[1])

                    print(data)

if __name__ == '__main__':
        main()

