#!/usr/bin/env python

import argparse, os, collections

parser = argparse.ArgumentParser(description='''
This script generates a country specific databases for use with
libpostal routines. Its a driver that runs build_country_db.sh
for every country found in the countries_languages.txt .

The driver will generate databases only for the countries that are
missing in the output directory''')

parser.add_argument('geodata_dir', type=str,
                    help='path to the directory containing geonames.tsv and postal_codes.tsv files')

parser.add_argument('addrdata_dir', type=str,
                    help='path to the directory containing files required for address parser training (formatted_addresses_tagged.random.tsv formatted_places_tagged.random.tsv)')

parser.add_argument('output_root_dir', type=str,
                    help='path to the directory where country specific subdirectory will be created')

args = parser.parse_args()

# load list of countries
countries = []
for l in open("countries_languages.txt", "r"):
    countries.append( l.split(':')[0] )

# add combinations to cover special cases in PBF downloads

# add Ireland together with UK to cover Ireland + Northern Ireland case
countries.append("gb-ie")

countries.append("ht-do")
countries.append("sn-gm")

# gcc states
countries.append("bh-kw-om-qa-sa-ae")

countries.append("il-ps")
countries.append("my-sg-bn")

### countries list: done ###

print "Loaded list of countries [%d]: " % len(countries),
for c in countries:
    print c,
print 

countries_done = []
for l in os.listdir(args.output_root_dir):
    if l != "compressed" and os.path.exists(os.path.join(args.output_root_dir, l, "address_parser", "address_parser.dat")):
        countries_done.append( l.lower() )
countries_done.sort()

print "\nList of countries that are ready [%d]: " % len(countries_done),
for c in countries_done:
    print c,
print

countries_todo = []
for l in countries:
    if l not in countries_done:
        countries_todo.append(l)

print "\nCountries not covered yet [%d]: " % len(countries_todo),
for c in countries_todo:
    print c,
print

##########################################

script = "Makefile"
f = open(script, "w")
f.write("# Generated by build_all_country_db\n\nall: ")
for c in countries_todo:
    C = c.upper()
    f.write(os.path.join(args.output_root_dir, C, "address_parser", "address_parser.dat") + " ")

f.write("\n\techo All done\n\n")
for c in countries_todo:
    C = c.upper()
    f.write(os.path.join(args.output_root_dir, C, "address_parser", "address_parser.dat") + ":\n" +
            '\t./build_country_db.sh "%s" "%s" "%s" %s\n\n' % (args.geodata_dir,
                                                               args.addrdata_dir,
                                                               args.output_root_dir,
                                                               C) )

print "\nExamine and run " + script + "\n"
