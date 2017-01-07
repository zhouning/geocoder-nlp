#ifndef GEOCODER_H
#define GEOCODER_H

#include "postal.h"

#include <sqlite3pp.h>

#include <vector>
#include <string>

namespace GeoNLP {

class Geocoder
{

public:
    struct GeoResult {
        long long int id;
        double latitude;
        double longitude;
        std::string title;
        std::string address;
        int levels_missing;
    };

public:
    Geocoder();
    Geocoder(const std::string &dbpath);

    void search(const std::vector< Postal::ParseResult > &parsed_query, std::vector<GeoResult> &result);

    int get_levels_in_title() const { return m_levels_in_title; }
    void set_levels_in_title(int l) { m_levels_in_title = l; }

    bool load(const std::string &dbpath);
    void drop();

protected:
    bool search(const std::vector<std::string> &parsed, std::vector<GeoResult> &result, size_t level=0,
            long long int range0=0, long long int range1=0);

    void get_name(long long int id, std::string &title, std::string &full, int levels_in_title);

protected:
    sqlite3pp::database m_db;
    int m_levels_in_title = 2;

    int m_min_missing_levels;
};

}
#endif // GEOCODER_H