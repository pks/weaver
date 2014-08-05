#pragma once

#include <string>

using namespace std;


namespace util {

  inline string
  json_escape(const string& s) { // FIXME: only inline?
    ostringstream os;
    for (auto it = s.cbegin(); it != s.cend(); it++) {
      switch (*it) {
        case '"':  os << "\\\""; break;
        case '\\': os << "\\\\"; break;
        case '\b': os << "\\b";  break;
        case '\f': os << "\\f";  break;
        case '\n': os << "\\n";  break;
        case '\r': os << "\\r";  break;
        case '\t': os << "\\t";  break;
        default:   os << *it;    break;
     }
   }
   return os.str();
 };

} // namespace util

