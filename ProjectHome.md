### Description ###

**RightLogLite** is a Perl script that parses and reformat ANY [Oracle Essbase](http://www.oracle.com/appserver/business-intelligence/essbase.html) server or application log.

**RightLogLite** is similar to [EssbaseRightLog](http://code.google.com/p/essbaserightlog/) as it parses Essbase logs, however **RightLogLite** doesn't require any external module but it contains then less features. As **EssbaseRightLog**, **RightLogLite** is intended to help Oracle Essbase® and Oracle Planning® database administrators and developers.

Essbase logs may be parsed whatever the delimiter defined in Essbase.cfg config file (please refer to `DELIMITEDMSG TRUE`, `DELIMITER` in Oracle’s Essbase® _Technical Reference_).
The idea was to make the logs really readable (one liner), making easy their analysis in a spreadsheet (common logical delimiter) or their insertion and querying in a relational database.

**RightLogLite** may be compiled as a Windows executable (exe) using PAR module (Perl Archive) available on CPAN.


### Options available ###

  * Search for specified files or directories (.LOG)
  * Advanced date formatting (US, European or standard ISO)
  * Headers insertion
  * Detailed message categories (please refer to _Essbase Server and Application Log Message Categories_ in DBAG)
  * String filtering
  * Custom separator


### Availability ###

**EssbaseRightLog** is available in the download section as a single Perl script and may be run under any environment hosting a Perl interpreter (no external module is required).
### Instructions of use ###

```
USAGE: perl RightLogLite.pl [-i <logfile(s)> | -p <directory>] [-o <outputfile>, -c, -d <arg>, -t, -s <arg>, -f <arg>, -x <outputfile>, -q, -h]

 -i specify log file(s), args: <logfile1[;logfile2;...]>
 -p specify log directory, recursive search for *.LOG files, args: <dir1[;dir2;...]>
 -o specify output file, arg: <outputfile>
 -c specify message categories
 -d specify date format, arg: <ISO|EUR|US>
 -t specify headers on top
 -s specify separator, arg: <*>
 -f specify filter (case sensitive), arg: <regex>
 -h display usage
```


### From the same author ###

outlinereader - Export Essbase outline structure and properties

jssauditmerger - Merge your Oracle Hyperion Essbase® spreadsheet audit logs for better analysis (Java version)

ssauditmerger - Merge your Oracle Hyperion Essbase® spreadsheet audit logs for better analysis (PERL version)

jrightlog  - Parse ANY Oracle Hyperion Essbase® server or application logs and generates a full, custom delimited, output for enhanced analysis (database, spreadsheet) (Java version)

essbaserightlog - Parse ANY Oracle Hyperion Essbase® server or application logs and generates a full, custom delimited, output for enhanced analysis (database, spreadsheet) (PERL version)