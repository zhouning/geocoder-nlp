#!/bin/bash

set -e

if [ $# -ne 4 ]; then
echo "
This script generates a country specific databases for use with
libpostal routines.

Usage:

$0 geodata_dir addrdata_dir output_root_dir country_code

where 

geodata_dir: path to the directory containing geonames.tsv
postal_codes.tsv files

addrdata_dir: path to the directory containing files required for
address parser training (formatted_addresses_tagged.random.tsv
formatted_places_tagged.random.tsv)

output_root_dir: path to the directory where country specific
subdirectory will be created

country_code: ISO 3166-1 alpha-2 country code (2 letters,
https://en.wikipedia.org/wiki/ISO_3166-1)

The country code can be specified in any case. It will be converted to
uppercase when making subdirectory under output_root_dir. Note that a
temporary files will be created under output_root_dir while this
script is running. This temporary directory will be removed at the end
of the script.

The script uses build_geodb and address_parser_train from
libpostal. Either ensure that these executables are in the path or
point the variable POSTAL_SRC_DIR in the script to a directory
containing these executables.

"
    exit -1
fi

#################################################################
### PATH TO LIBPOSTAL SRC DIRECTORY WITH COMPILED EXECUTABLES ###

POSTAL_SRC_DIR=../libpostal/src

#################################################################

GEODATA=$1
ADDRDATA=$2
OUTPUT=$3
COUNTRY=$4

TMPDATA="$OUTPUT/tmp-$COUNTRY-`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1`"

COUNTRY_LOWER="${COUNTRY,,}"
COUNTRY_UPPER="${COUNTRY^^}"

COUNTRY_DIR="$OUTPUT/$COUNTRY_UPPER"

PATH="$POSTAL_SRC_DIR:$PATH"

OUTPUT_ADDRESS="$TMPDATA/address.tsv"

rm -rf "$COUNTRY_DIR"

mkdir -p "$TMPDATA"
mkdir -p "$COUNTRY_DIR/address_parser"
mkdir -p "$COUNTRY_DIR/geodb"

# Geo data
for file in geonames.tsv postal_codes.tsv; do
    echo "Geo data preparation: $file / $COUNTRY_UPPER" 
    grep $'\t'$COUNTRY_UPPER$'\t' "$GEODATA/$file" > "$TMPDATA/$file" || true
done

echo "Geo data ready"

# Addresses
cp /dev/null "$OUTPUT_ADDRESS"
#for file in formatted_addresses_tagged.random.tsv openaddresses_formatted_addresses_tagged.random.tsv formatted_places_tagged.random.tsv; do
for file in formatted_addresses_tagged.random.tsv formatted_places_tagged.random.tsv; do
    echo "Address data preparation: $file / $COUNTRY_LOWER" 
    grep $'\t'$COUNTRY_LOWER$'\t' "$ADDRDATA/$file" >> "$OUTPUT_ADDRESS" || true
done

echo "Randomize addresses"
shuf -o "$OUTPUT_ADDRESS.shuf" "$OUTPUT_ADDRESS"
mv "$OUTPUT_ADDRESS.shuf" "$OUTPUT_ADDRESS"

########################################################################

echo "Build GEO database"
build_geodb "$TMPDATA" "$COUNTRY_DIR/geodb"

echo "Address training"
time address_parser_train "$OUTPUT_ADDRESS" "$COUNTRY_DIR/address_parser"

echo "Removing temporary directory"
rm -rf "$TMPDATA"