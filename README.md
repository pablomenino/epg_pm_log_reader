<h3 align="center">epg_pm_log_reader</h3>
<p align="center">epg_pm_log_reader - Is a PM Log (Performance Management Log) parser script to export Statistics and Plot images.</p>

<p align="center">
<a href="https://github.com/pablomenino/epg_pm_log_reader/releases"><img src="https://img.shields.io/github/release/pablomenino/epg_pm_log_reader.svg"></a>
<a href="./LICENSE"><img src="https://img.shields.io/github/license/pablomenino/epg_pm_log_reader.svg"></a>
</p>


epg_pm_log_reader - Is a PM Log (Performance Management Log) parser script to export Statistics and Plot images.

Tested on Virtual EPG 2.

## Table of contents

* [How to Use](#how-to-use)

## <a name="how-to-use">How to Use

#### Requirements

* Perl 5.8

#### Usage

```
EPG PM Log Reader - Version 0.4.4
Copyright © 2019 - Pablo Meniño <pablo.menino@gmail.com>

Usage: ./epg_pm_log_reader.pl [options]

options:
  --print_help                             - Print this help
  --print_version                          - Print version info
  --pm_directory=/path/to/pm/              - Where the PM Log files are
  --get_board_allocation                   - Export CPU usage
  --get_pgw_apn_gx                         - Export PGW APN Gx Statistic
  --get_pgw_apn_radius                     - Export PGW APN Radius Statistic

  --gx_filter_apn_list=apnlist             - Filter Gx Statistics by APN
                                           - Example:
                                           - --gx_filter_apn_list=apn1.domain.com,apn2.domain.com
                                           - --gx_filter_apn_list=apn1.domain.com
                                           - If no apn list provided, all data is exported

  --gx_filter_pcrf_list=pcrflist           - Filter Gx Statistics by PCRF
                                           - Example:
                                           - --gx_filter_pcrf_list=GX_DAS,GX_SAPC
                                           - --gx_filter_pcrf_list=GX_DAS
                                           - If no PCRF list provided, all data is exported

  --radius_filter_apn_list=apnlist         - Filter Radius Statistics by APN
                                           - Example:
                                           - --radius_filter_apn_list=apn1.domain.com,apn2.domain.com
                                           - --radius_filter_apn_list=apn1.domain.com
                                           - If no apn list provided, all data is exported

  --radius_filter_server_list=serverlist   - Filter Radius Statistics by Server
                                           - Example:
                                           - --radius_filter_server_list=192.168.0.1,192.168.1.100
                                           - --radius_filter_server_list=192.168.0.200
                                           - If no server list provided, all data is exported

  --report_title=title_name                - Prepend text to all report files
  --verbose_mode                           - Enable detailed output mode for troubleshooting.

Note: * By default the imput directory to find PM Log files are: ./pm_files/ and exported files: ./exported/
      * If no report_title is provided, the node name is used.
      * This script needs 3 imput files to be able to create a chart.
      * Gnuplot can't create charts with empty data (Filter APN names if there is no data in some APN).
```