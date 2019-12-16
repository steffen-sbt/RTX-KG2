#!/usr/bin/env python3
'''dgidb_tsv_to_kg_json.py: Extracts a KG2 JSON file from the DGIdb interactions file in TSV format

   Usage: dgidb_tsv_to_kg_json.py [--test] <inputFile.tsv> <outputFile.json>
'''

__author__ = 'Stephen Ramsey'
__copyright__ = 'Oregon State University'
__credits__ = ['Stephen Ramsey']
__license__ = 'MIT'
__version__ = '0.1.0'
__maintainer__ = ''
__email__ = ''
__status__ = 'Prototype'

import argparse
import kg2_util
import re
import sys

DGIDB_BASE_IRI = 'http://www.dgidb.org'
DGIDB_CURIE_PREFIX = 'DGIDB'
RE_PMID = re.compile('([^\[]+)[\[,\{](PMID: \d+)')

GTPI_IRI_BASE = 'https://www.guidetopharmacology.org/'
GTPI_CURIE_PREFIX = 'GTPI'
GTPI_LIGAND_SUFFIX = 'GRAC/LigandDisplayForward?ligandId='

TTD_IRI_BASE = 'https://db.idrblab.org/ttd/'
TTD_CURIE_PREFIX = 'TTD'


def get_args():
    arg_parser = argparse.ArgumentParser(description='dgidb_tsv_to_kg_json.py: builds a KG2 JSON file from the DGIdb interactions.tsv file')
    arg_parser.add_argument('--test', dest='test', action="store_true", default=False)
    arg_parser.add_argument('inputFile', type=str)
    arg_parser.add_argument('outputFile', type=str)
    return arg_parser.parse_args()


def make_kg2_graph(input_file_name: str, test_mode: bool = False):
    nodes = []
    edges = []
    line_ctr = 0
    update_date = None
    with open(input_file_name, 'r') as input_file:
        for line in input_file:
            line = line.rstrip("\n")
            if line.startswith('#'):
                update_date = line.replace('#', '')
                continue
            if line.startswith('gene_name\t'):
                continue
            line_ctr += 1
            if test_mode and line_ctr > 10000:
                break
            fields = line.split("\t")
            [gene_name,
             gene_claim_name,
             entrez_id,
             interaction_claim_source,
             interaction_types,
             drug_claim_name,
             drug_claim_primary_name,
             drug_name,
             drug_chembl_id,
             PMIDs] = fields
            if entrez_id != "":
                object_curie_id = 'NCBIGene:' + entrez_id
                if drug_chembl_id != "":
                    subject_curie_id = 'CHEMBL.COMPOUND:' + drug_chembl_id
                else:
                    if drug_claim_name != "":
                        node_pubs_list = []
                        subject_curie_id = None
                        if interaction_claim_source == "GuideToPharmacologyInteractions":
                            subject_curie_id = GTPI_CURIE_PREFIX + ':' + drug_claim_name
                            pmid_match = RE_PMID.match(drug_claim_primary_name)
                            if pmid_match is not None:
                                node_pubs_list = [pmid_match[2].replace(' ', '').strip()]
                                node_name = pmid_match[1].strip()
                            else:
                                node_name = drug_claim_primary_name
                            node_iri = GTPI_IRI_BASE + GTPI_LIGAND_SUFFIX + drug_claim_name
                            provided_by = GTPI_IRI_BASE
                        elif interaction_claim_source == "TTD":
                            subject_curie_id = TTD_CURIE_PREFIX + ':' + drug_claim_name
                            node_name = drug_claim_primary_name
                            node_iri = TTD_IRI_BASE + drug_claim_name
                            provided_by = TTD_IRI_BASE
                        if subject_curie_id is not None:
                            node_dict = kg2_util.make_node(subject_curie_id,
                                                           node_iri,
                                                           node_name,
                                                           'chemical_substance',
                                                           update_date,
                                                           provided_by)
                            node_dict['publications'] = node_pubs_list
                            nodes.append(node_dict)
                if subject_curie_id is None:
                    print("DGIDB: no controlled ID was provided for this drug: " + drug_claim_primary_name + "; source DB: " + interaction_claim_source, file=sys.stderr)
                    continue
                if interaction_types == "":
                    interaction_types = "affects"
                pmids_list = []
                if PMIDs.strip() != "":
                    pmids_list = [('PMID:' + pmid.strip()) for pmid in PMIDs.split(',')]
                interaction_list = interaction_types.split(',')
                for interaction in interaction_list:
                    interaction = interaction.replace(' ', '_')
                    edge_dict = kg2_util.make_edge(subject_curie_id,
                                                   object_curie_id,
                                                   DGIDB_BASE_IRI + '/' +
                                                   kg2_util.convert_snake_case_to_camel_case(interaction),
                                                   DGIDB_CURIE_PREFIX + ':' + interaction,
                                                   interaction,
                                                   DGIDB_BASE_IRI,
                                                   update_date)
                    edge_dict['publications'] = pmids_list
                    edges.append(edge_dict)
    return {'nodes': nodes,
            'edges': edges}


if __name__ == '__main__':
    args = get_args()
    input_file_name = args.inputFile
    output_file_name = args.outputFile
    test_mode = args.test
    graph = make_kg2_graph(input_file_name, test_mode)
    kg2_util.save_json(graph, output_file_name, test_mode)
