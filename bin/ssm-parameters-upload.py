## Assumes an input CSV with four columns headed with a header row whose values are:
## 1. NamespacePrefix
## 2. Parameter
## 3. Type (SecureString or String)
## 4. Value
## 
## Where the SSM parameter being created is the concatenation of NamespacePrefix + '/' + Parameter

from csv import DictReader
from operator import itemgetter
import subprocess
import argparse

delimiter_character = ','

parser = argparse.ArgumentParser()
parser.add_argument("--file", type=argparse.FileType('r', encoding='UTF-8'), help="name of CSV file with SSM parameters", required=True, dest="csv_file", action="store")
parser.add_argument("--key", help="keyid for encrypting SecureString SSM parameters", required=True, dest="key_id", action="store")
parser.add_argument("--region", help="AWS region in which to store SSM parameters", required=True, dest="AWSRegion", action="store")
args = parser.parse_args()

with args.csv_file as params:
    params_reader = DictReader(params, delimiter = delimiter_character)
    for row in params_reader:
        if row['Type'] == "SecureString":
            subprocess.run(['aws', 'ssm', 'put-parameter', '--name', row['NamespacePrefix'] + "/" + row['Parameter'], '--type', row['Type'], '--value', row['Value'], '--region', args.AWSRegion, '--key-id', args.key_id])
            # subprocess.run(['aws', 'ssm', 'put-parameter', '--name', row['NamespacePrefix'] + "/" + row['Parameter'], '--type', row['Type'], '--value', row['Value'], '--region', AWSRegion, '--key-id', key_id])
        elif row['Type'] == "String":
            subprocess.run(['aws', 'ssm', 'put-parameter', '--name', row['NamespacePrefix'] + "/" + row['Parameter'], '--type', row['Type'], '--value', row['Value'], '--region', args.AWSRegion])
        else:
            print('\n' + "Input record has invalid Type field - param = " + row['Parameter'])
