#!/usr/bin/perl

#----------------------------------------------------------------------------------------
# EPG PM Log Reader Script
# Version: 0.4.2
# 
# WebSite:
# https://github.com/pablomenino/epg_pm_log_reader
# 
# Copyright © 2019 - Pablo Meniño <pablo.menino@gmail.com>
#----------------------------------------------------------------------------------------

#----------------------------------------------------------------------
# Use declaration -----------------------------------------------------

# Use local Lib (Perl5)
use local::lib;

use strict;
use warnings;

use List::Util qw(min max);

# For parsing XML
use XML::Simple;

# For debug output
use Data::Dumper;

# Switch
use Switch;

# GnuPlot
use Chart::Gnuplot;

#----------------------------------------------------------------------
# Var declaration -----------------------------------------------------

# Version Control
my $version = "0.4.2";

# True or False type
use constant false => 0;
use constant true  => 1;

# By default process all APN and Servers/PCRF
my $gx_apnlist = "all";
my @gx_apnlist_array;

my $radius_apnlist = "all";
my @radius_apnlist_array;

my $gx_pcrflist = "all";
my @gx_pcrflist_array;

my $radius_serverlist = "all";
my @radius_serverlist_array;

# Default directory
my $pm_log_directory = "./pm_files";
my $exported_directory = "./exported";

# Operations
my $get_pgw_apn_gx = false;
my $get_pgw_apn_radius = false;

# Statistics
my $files_count = 0;
my $apn_count = 0;
my $radius_count = 0;

my $report_title = "";

# Creates an unusual filename based on nanoseconds so that
# you don't accidentally overwrite another report.
my $nano = `date '+%Y-%m-%d_%H-%M-%S'`;
# Remove return line
chomp($nano);

# CSV Gx Header
my $p_gx_header_time = "time";
my $p_gx_header_apn = "apn";
my $p_gx_header_pcrf = "pcrf";
my $p_gx_header_1 = "ccr-initial-sent";
my $p_gx_header_1_delta = "ccr-initial-sent Delta";
my $p_gx_header_2 = "ccr-initial-failed";
my $p_gx_header_2_delta = "ccr-initial-failed Delta";
my $p_gx_header_3 = "ccr-update-sent";
my $p_gx_header_3_delta = "ccr-update-sent Delta";
my $p_gx_header_4 = "ccr-update-failed";
my $p_gx_header_4_delta = "ccr-update-failed Delta";
my $p_gx_header_5 = "ccr-termination-sent";
my $p_gx_header_5_delta = "ccr-termination-sent Delta";
my $p_gx_header_6 = "ccr-termination-failed";
my $p_gx_header_6_delta = "ccr-termination-failed Delta";
my $p_gx_header_7 = "user-service-denied";
my $p_gx_header_7_delta = "user-service-denied Delta";
my $p_gx_header_8 = "user-unknown";
my $p_gx_header_8_delta = "user-unknown Delta";
my $p_gx_header_9 = "authorization-failure";
my $p_gx_header_9_delta = "authorization-failure Delta";
my $p_gx_header_10 = "authentication-failure";
my $p_gx_header_10_delta = "authentication-failure Delta";
my $p_gx_header_11 = "unknown-session-id";
my $p_gx_header_11_delta = "unknown-session-id Delta";
my $p_gx_header_12 = "active-gx-sessions";
my $p_gx_header_13 = "pending-transaction-received";
my $p_gx_header_13_delta = "pending-transaction-received Delta";
my $p_gx_header_14 = "pending-transaction-sent";
my $p_gx_header_14_delta = "pending-transaction-sent Delta";
my $p_gx_header_15 = "pending-transaction-loop-termination";
my $p_gx_header_15_delta = "pending-transaction-loop-termination Delta";
my $p_gx_header_16 = "temporarily-offline-sessions";
my $p_gx_header_16_delta = "temporarily-offline-sessions Delta";
my $p_gx_header_17 = "permanently-offline-sessions";
my $p_gx_header_17_delta = "permanently-offline-sessions Delta";
my $p_gx_header_18 = "rar-received-nt";
my $p_gx_header_18_delta = "rar-received-nt Delta";

# CSV Gx data
my $p_gx_data_1 = "";
my $p_gx_data_1_delta = "";
my $p_gx_data_1_delta_value = 0;
my $p_gx_data_2 = "";
my $p_gx_data_2_delta = "";
my $p_gx_data_2_delta_value = 0;
my $p_gx_data_3 = "";
my $p_gx_data_3_delta = "";
my $p_gx_data_3_delta_value = 0;
my $p_gx_data_4 = "";
my $p_gx_data_4_delta = "";
my $p_gx_data_4_delta_value = 0;
my $p_gx_data_5 = "";
my $p_gx_data_5_delta = "";
my $p_gx_data_5_delta_value = 0;
my $p_gx_data_6 = "";
my $p_gx_data_6_delta = "";
my $p_gx_data_6_delta_value = 0;
my $p_gx_data_7 = "";
my $p_gx_data_7_delta = "";
my $p_gx_data_7_delta_value = 0;
my $p_gx_data_8 = "";
my $p_gx_data_8_delta = "";
my $p_gx_data_8_delta_value = 0;
my $p_gx_data_9 = "";
my $p_gx_data_9_delta = "";
my $p_gx_data_9_delta_value = 0;
my $p_gx_data_10 = "";
my $p_gx_data_10_delta = "";
my $p_gx_data_10_delta_value = 0;
my $p_gx_data_11 = "";
my $p_gx_data_11_delta = "";
my $p_gx_data_11_delta_value = 0;
my $p_gx_data_12 = "";
my $p_gx_data_13 = "";
my $p_gx_data_13_delta = "";
my $p_gx_data_13_delta_value = 0;
my $p_gx_data_14 = "";
my $p_gx_data_14_delta = "";
my $p_gx_data_14_delta_value = 0;
my $p_gx_data_15 = "";
my $p_gx_data_15_delta = "";
my $p_gx_data_15_delta_value = 0;
my $p_gx_data_16 = "";
my $p_gx_data_16_delta = "";
my $p_gx_data_16_delta_value = 0;
my $p_gx_data_17 = "";
my $p_gx_data_17_delta = "";
my $p_gx_data_17_delta_value = 0;
my $p_gx_data_18 = "";
my $p_gx_data_18_delta = "";
my $p_gx_data_18_delta_value = 0;

# CVS Gx Report Hash
my %csv_gx_report;

# CSV Radius Header
my $p_radius_header_time = "time";
my $p_radius_header_apn = "apn";
my $p_radius_header_server = "server";
my $p_radius_header_1 = "accounting-requests";
my $p_radius_header_1_delta = "accounting-requests Delta";
my $p_radius_header_2 = "accounting-responses";
my $p_radius_header_2_delta = "accounting-responses Delta";
my $p_radius_header_3 = "accounting-request-timeouts";
my $p_radius_header_3_delta = "accounting-request-timeouts Delta";
my $p_radius_header_4 = "server-accounting-request-retransmits";
my $p_radius_header_4_delta = "server-accounting-request-retransmits Delta";
my $p_radius_header_5 = "invalid-authenticators";
my $p_radius_header_5_delta = "invalid-authenticators Delta";

# CSV Radius data
my $p_radius_data_1 = "";
my $p_radius_data_1_delta = "";
my $p_radius_data_1_delta_value = 0;
my $p_radius_data_2 = "";
my $p_radius_data_2_delta = "";
my $p_radius_data_2_delta_value = 0;
my $p_radius_data_3 = "";
my $p_radius_data_3_delta = "";
my $p_radius_data_3_delta_value = 0;
my $p_radius_data_4 = "";
my $p_radius_data_4_delta = "";
my $p_radius_data_4_delta_value = 0;
my $p_radius_data_5 = "";
my $p_radius_data_5_delta = "";
my $p_radius_data_5_delta_value = 0;

# CVS Radius Report Hash
my %csv_radius_report;

# CSV separator char
my $csv_separator_var = "|";

# Verbose mode
my $verbose_mode = false;

#----------------------------------------------------------------------
# Functions - get_arg -------------------------------------------------

sub get_arg()
{

    foreach (@ARGV)
    {
        if ($_ =~ m/^\-\-pm_directory=.+/)
        {
            $pm_log_directory = (split '=',$_)[1];
            # remove trailing slash
            $pm_log_directory = $1 if($pm_log_directory=~/(.*)\/$/);
        }
        if ($_ =~ m/^\-\-exported_directory=.+/)
        {
            $exported_directory = (split '=',$_)[1];
            # remove trailing slash
            $exported_directory = $1 if($exported_directory=~/(.*)\/$/);
        }
        elsif ($_ =~ m/^\-\-report_title=.+/)
        {
            $report_title = (split '=',$_)[1];
        }
        elsif ($_ =~ m/^\-\-get_pgw_apn_gx$/)
        {
            $get_pgw_apn_gx = true;
        }
        elsif ($_ =~ m/^\-\-gx_filter_apn_list=.+/)
        {
            $gx_apnlist = (split '=',$_)[1];
            @gx_apnlist_array = split(/,/, $gx_apnlist);
            $gx_apnlist = "array";
        }
        elsif ($_ =~ m/^\-\-gx_filter_pcrf_list=.+/)
        {
            $gx_pcrflist = (split '=',$_)[1];
            @gx_pcrflist_array = split(/,/, $gx_pcrflist);
            $gx_pcrflist = "array";
        }
        elsif ($_ =~ m/^\-\-get_pgw_apn_radius$/)
        {
            $get_pgw_apn_radius = true;
        }
        elsif ($_ =~ m/^\-\-radius_filter_apn_list=.+/)
        {
            $radius_apnlist = (split '=',$_)[1];
            @radius_apnlist_array = split(/,/, $radius_apnlist);
            $radius_apnlist = "array";
        }
        elsif ($_ =~ m/^\-\-radius_filter_server_list=.+/)
        {
            $radius_serverlist = (split '=',$_)[1];
            @radius_serverlist_array = split(/,/, $radius_serverlist);
            $radius_serverlist = "array";
        }
        elsif ($_ =~ m/^\-\-verbose_mode$/)
        {
            $verbose_mode = true;
        }
    }
}

#----------------------------------------------------------------------
# Functions - print_help ----------------------------------------------

sub print_help()
{
	print_version();
	print "Usage: $0 [options]\n";
	print "\n";
	print "options:\n";
	print "  --print_help                             - Print this help\n";
	print "  --print_version                          - Print version info\n";
	print "  --pm_directory=/path/to/pm/              - Where the PM Log files are\n";
	print "  --get_pgw_apn_gx                         - Export PGW APN Gx Statistic\n";
    print "  --get_pgw_apn_radius                     - Export PGW APN Radius Statistic\n";
	print "\n";
	print "  --gx_filter_apn_list=apnlist             - Filter Gx Statistics by APN\n";
    print "                                           - Example:\n";
    print "                                           - --gx_filter_apn_list=apn1.domain.com,apn2.domain.com\n";
    print "                                           - --gx_filter_apn_list=apn1.domain.com\n";
    print "                                           - If no apn list provided, all data is exported\n";
	print "\n";
	print "  --gx_filter_pcrf_list=pcrflist           - Filter Gx Statistics by PCRF\n";
    print "                                           - Example:\n";
    print "                                           - --gx_filter_pcrf_list=GX_DAS,GX_SAPC\n";
    print "                                           - --gx_filter_pcrf_list=GX_DAS\n";
    print "                                           - If no PCRF list provided, all data is exported\n";
	print "\n";
	print "  --radius_filter_apn_list=apnlist         - Filter Radius Statistics by APN\n";
    print "                                           - Example:\n";
    print "                                           - --radius_filter_apn_list=apn1.domain.com,apn2.domain.com\n";
    print "                                           - --radius_filter_apn_list=apn1.domain.com\n";
    print "                                           - If no apn list provided, all data is exported\n";
	print "\n";
	print "  --radius_filter_server_list=serverlist   - Filter Radius Statistics by Server\n";
    print "                                           - Example:\n";
    print "                                           - --radius_filter_server_list=192.168.0.1,192.168.1.100\n";
    print "                                           - --radius_filter_server_list=192.168.0.200\n";
    print "                                           - If no server list provided, all data is exported\n";
	print "\n";
    print "  --report_title=title_name                - Prepend text to all report files\n";
    print "  --verbose_mode                           - Enable detailed output mode for troubleshooting.\n";
	print "\n";
    print "Note: By default the imput directory to find PM Log files are: ./pm_files/ and exported files: ./exported/\n";
	print "\n";
}

#----------------------------------------------------------------------
# Functions - print_version -------------------------------------------

sub print_version()
{
	print "EPG PM Log Reader - Version $version\n";
	print "Copyright © 2019 - Pablo Meniño <pablo.menino\@gmail.com>\n";
	print "\n";
}

#----------------------------------------------------------------------
# Functions - save_gx_plot --------------------------------------------

sub save_gx_plot()
{

    # Export records
    foreach my $apn (sort keys %csv_gx_report)
    {
        foreach my $pcrf (sort keys %{ $csv_gx_report{$apn} })
        {
            # Open file
            my $filename = "";
            if ( $report_title ne "")
            {
                $filename = $exported_directory . "/" . $report_title . "_plot_gx_" . $apn . "_" . "$pcrf" . "_"  . $nano . ".png";
            }
            else
            {
                $filename = $exported_directory . "/report_plot_gx_" . $apn . "_" . "$pcrf" . "_"  . $nano . ".png";
            }

            my @array_plot_data_time;
            my @array_plot_data_p1_delta;
            my @array_plot_data_p2_delta;
            my @array_plot_data_p3_delta;
            my @array_plot_data_p4_delta;
            my @array_plot_data_p5_delta;
            my @array_plot_data_p6_delta;
            my @array_plot_data_p12;
            my @array_plot_data_p18_delta;

            foreach my $data_array (@{$csv_gx_report{$apn}{$pcrf}} )
            {

                my @fields = (split '\|', $data_array);

                push (@array_plot_data_time, substr($fields[0],0,19));
                push (@array_plot_data_p1_delta, $fields[2]);
                push (@array_plot_data_p2_delta, $fields[4]);
                push (@array_plot_data_p3_delta, $fields[6]);
                push (@array_plot_data_p4_delta, $fields[8]);
                push (@array_plot_data_p5_delta, $fields[10]);
                push (@array_plot_data_p6_delta, $fields[12]);
                push (@array_plot_data_p12, $fields[23]);
                push (@array_plot_data_p18_delta, $fields[35]);
            }

            my $xlabel_time_init = $array_plot_data_time[0];
            $xlabel_time_init =~ tr/T/ /;
            my $xlabel_time_end = $array_plot_data_time[$#array_plot_data_time];
            $xlabel_time_end =~ tr/T/ /;

            my @yrange_max_array;
            push (@yrange_max_array, max(@array_plot_data_p1_delta));
            push (@yrange_max_array, max(@array_plot_data_p2_delta));
            push (@yrange_max_array, max(@array_plot_data_p3_delta));
            push (@yrange_max_array, max(@array_plot_data_p4_delta));
            push (@yrange_max_array, max(@array_plot_data_p5_delta));
            push (@yrange_max_array, max(@array_plot_data_p6_delta));
            push (@yrange_max_array, max(@array_plot_data_p12));
            push (@yrange_max_array, max(@array_plot_data_p18_delta));


            # Initiate the chart object
            my $chart = Chart::Gnuplot->new(
                output => $filename,
                title  => "Statistics Gx",
                xlabel => "Init time: " . $xlabel_time_init . ", End time: " . $xlabel_time_end,
                ylabel => "APN: " . $apn . ", PCRF: " . $pcrf,
                yrange => [0, max(@yrange_max_array)],
                grid    => 'on',
                imagesize => "1.8, 1.5",
                timeaxis => "x",
                bg     => {
                            color   => "#c9c9ff",
                            density => 0.2,
                        },
                legend => {position => 'right'},
                legend => {
                            border => {
                            linetype => 2,
                            width    => 2,
                            color    => "blue",
                            },
                        width  => 2,
                        height => 2,
                        },
            );

            my $x1 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p1_delta,
                yrange => [0, max(@array_plot_data_p1_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_1_delta,
                color => "#AA91E7",
                timefmt => '%Y-%m-%dT%H:%M:%S', 
                );

            my $x2 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p2_delta,
                yrange => [0, max(@array_plot_data_p2_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_2_delta,
                color => "#5E9BE7",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x3 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p3_delta,
                yrange => [0, max(@array_plot_data_p3_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_3_delta,
                color => "#4DCDAD",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x4 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p4_delta,
                yrange => [0, max(@array_plot_data_p4_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_4_delta,
                color => "#9FD371",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x5 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p5_delta,
                yrange => [0, max(@array_plot_data_p5_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_5_delta,
                color => "#FFCD62",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x6 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p6_delta,
                yrange => [0, max(@array_plot_data_p6_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_6_delta,
                color => "#909090",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x12 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p12,
                yrange => [0, max(@array_plot_data_p12)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_12,
                color => "#090061",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x18 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p18_delta,
                yrange => [0, max(@array_plot_data_p18_delta)],
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_gx_header_18_delta,
                color => "#EB5766",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            # Plot the graph
            $chart->plot2d($x1, $x2, $x3, $x4, $x5, $x6, $x12, $x18);

        }
    }
}

#----------------------------------------------------------------------
# Functions - save_radius_plot ----------------------------------------

sub save_radius_plot()
{

    # Export records
    foreach my $apn (sort keys %csv_radius_report)
    {
        foreach my $server (sort keys %{ $csv_radius_report{$apn} })
        {
            # Open file
            my $filename = "";
            if ( $report_title ne "")
            {
                $filename = $exported_directory . "/" . $report_title . "_plot_radius_" . $apn . "_" . "$server" . "_"  . $nano . ".png";
            }
            else
            {
                $filename = $exported_directory . "/report_plot_radius_" . $apn . "_" . "$server" . "_"  . $nano . ".png";
            }

            my @array_plot_data_time;
            my @array_plot_data_p1_delta;
            my @array_plot_data_p2_delta;
            my @array_plot_data_p3_delta;
            my @array_plot_data_p4_delta;
            my @array_plot_data_p5_delta;

            foreach my $data_array (@{$csv_radius_report{$apn}{$server}} )
            {

                my @fields = (split '\|', $data_array);

                push (@array_plot_data_time, substr($fields[0],0,19));
                push (@array_plot_data_p1_delta, $fields[2]);
                push (@array_plot_data_p2_delta, $fields[4]);
                push (@array_plot_data_p3_delta, $fields[6]);
                push (@array_plot_data_p4_delta, $fields[8]);
                push (@array_plot_data_p5_delta, $fields[10]);
            }

            my $xlabel_time_init = $array_plot_data_time[0];
            $xlabel_time_init =~ tr/T/ /;
            my $xlabel_time_end = $array_plot_data_time[$#array_plot_data_time];
            $xlabel_time_end =~ tr/T/ /;

            my @yrange_max_array;
            push (@yrange_max_array, max(@array_plot_data_p1_delta));
            push (@yrange_max_array, max(@array_plot_data_p2_delta));
            push (@yrange_max_array, max(@array_plot_data_p3_delta));
            push (@yrange_max_array, max(@array_plot_data_p4_delta));
            push (@yrange_max_array, max(@array_plot_data_p5_delta));

            # Initiate the chart object
            my $chart = Chart::Gnuplot->new(
                output => $filename,
                title  => "Statistics Radius",
                xlabel => "Init time: " . $xlabel_time_init . ", End time: " . $xlabel_time_end,
                ylabel => "APN: " . $apn . ", Server: " . $server,
                yrange => [0, max(@yrange_max_array)],
                grid    => 'on',
                imagesize => "1.8, 1.5",
                timeaxis => "x",
                bg     => {
                            color   => "#c9c9ff",
                            density => 0.2,
                        },
                legend => {position => 'right'},
                legend => {
                            border => {
                            linetype => 2,
                            width    => 2,
                            color    => "blue",
                            },
                        width  => 2,
                        height => 2,
                        },
            );

            my $x1 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p1_delta,
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_radius_header_1_delta,
                color => "#AA91E7",
                timefmt => '%Y-%m-%dT%H:%M:%S', 
            );

            my $x2 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p2_delta,
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_radius_header_2_delta,
                color => "#5E9BE7",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x3 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p3_delta,
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_radius_header_3_delta,
                color => "#4DCDAD",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x4 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p4_delta,
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_radius_header_4_delta,
                color => "#9FD371",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            my $x5 = Chart::Gnuplot::DataSet->new(
                xdata  => \@array_plot_data_time,
                ydata  => \@array_plot_data_p5_delta,
                style  => 'linespoints',
                pointtype => 30,
                width => 3,
                title  => $p_radius_header_5_delta,
                color => "#FFCD62",
                timefmt => '%Y-%m-%dT%H:%M:%S',
            );

            # Plot the graph
            $chart->plot2d($x1, $x2, $x3, $x4, $x5);

        }
    }
}

#----------------------------------------------------------------------
# Functions - save_gx_report ------------------------------------------

sub save_gx_report()
{

    my $push_string = "";
    $push_string = $push_string . $p_gx_header_apn . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_pcrf . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_time . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_1 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_1_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_2 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_2_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_3 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_3_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_4 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_4_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_5 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_5_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_6 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_6_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_7 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_7_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_8 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_8_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_9 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_9_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_10 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_10_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_11 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_11_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_12 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_13 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_13_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_14 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_14_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_15 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_15_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_16 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_16_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_17 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_17_delta . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_18 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_header_18_delta;

	print "\n" if ($verbose_mode);

    # Open file
    my $filename = "";
    if ( $report_title ne "")
    {
        $filename = $exported_directory . "/" . $report_title . "_report_gx_" . $nano . ".csv";
    }
    else
    {
        $filename = $exported_directory . "/report_gx_" . $nano . ".csv";
    }

    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    
    # Print Header in file.
    print $fh $push_string . "\n";

    # Export records
    foreach my $apn (sort keys %csv_gx_report)
    {
        foreach my $pcrf (sort keys %{ $csv_gx_report{$apn} })
        {
            foreach my $data_array (@{$csv_gx_report{$apn}{$pcrf}} )
            {
                print $fh  $apn . $csv_separator_var . $pcrf . $csv_separator_var . $data_array . "\n";
            }
        }
    }

    close $fh;
}

#----------------------------------------------------------------------
# Functions - calculate_delta_gx --------------------------------------

sub calculate_delta_gx()
{

    # Export records
    foreach my $apn (sort keys %csv_gx_report)
    {
        foreach my $pcrf (sort keys %{ $csv_gx_report{$apn} })
        {

            for my $i (0 .. $#{$csv_gx_report{$apn}{$pcrf}})
            {

                my $data_element = shift @{$csv_gx_report{$apn}{$pcrf}};
                my @fields = (split '\|', $data_element);

                if ($i eq 0)
                {

                    $data_element = $fields[0] . $csv_separator_var;
                    $data_element = $data_element . $fields[1] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[2] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[3] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[4] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[5] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[6] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[7] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[8] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[9] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[10] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[11] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;

                    $data_element = $data_element . $fields[12] . $csv_separator_var;

                    $data_element = $data_element . $fields[13] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[14] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[15] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[16] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[17] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[18] . $csv_separator_var;
                    $data_element = $data_element . "0";

                    $p_gx_data_1_delta_value = $fields[1];
                    $p_gx_data_2_delta_value = $fields[2];
                    $p_gx_data_3_delta_value = $fields[3];
                    $p_gx_data_4_delta_value = $fields[4];
                    $p_gx_data_5_delta_value = $fields[5];
                    $p_gx_data_6_delta_value = $fields[6];
                    $p_gx_data_7_delta_value = $fields[7];
                    $p_gx_data_8_delta_value = $fields[8];
                    $p_gx_data_9_delta_value = $fields[9];
                    $p_gx_data_10_delta_value = $fields[10];
                    $p_gx_data_11_delta_value = $fields[11];

                    $p_gx_data_13_delta_value = $fields[13];
                    $p_gx_data_14_delta_value = $fields[14];
                    $p_gx_data_15_delta_value = $fields[15];
                    $p_gx_data_16_delta_value = $fields[16];
                    $p_gx_data_17_delta_value = $fields[17];
                    $p_gx_data_18_delta_value = $fields[18];

                }
                else
                {

                    $data_element = $fields[0] . $csv_separator_var;
                    $data_element = $data_element . $fields[1] . $csv_separator_var;
                    $data_element = $data_element . ($fields[1] - $p_gx_data_1_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[2] . $csv_separator_var;
                    $data_element = $data_element . ($fields[2] - $p_gx_data_2_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[3] . $csv_separator_var;
                    $data_element = $data_element . ($fields[3] - $p_gx_data_3_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[4] . $csv_separator_var;
                    $data_element = $data_element . ($fields[4] - $p_gx_data_4_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[5] . $csv_separator_var;
                    $data_element = $data_element . ($fields[5] - $p_gx_data_5_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[6] . $csv_separator_var;
                    $data_element = $data_element . ($fields[6] - $p_gx_data_6_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[7] . $csv_separator_var;
                    $data_element = $data_element . ($fields[7] - $p_gx_data_7_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[8] . $csv_separator_var;
                    $data_element = $data_element . ($fields[8] - $p_gx_data_8_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[9] . $csv_separator_var;
                    $data_element = $data_element . ($fields[9] - $p_gx_data_9_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[10] . $csv_separator_var;
                    $data_element = $data_element . ($fields[10] - $p_gx_data_10_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[11] . $csv_separator_var;
                    $data_element = $data_element . ($fields[11] - $p_gx_data_11_delta_value) . $csv_separator_var;

                    $data_element = $data_element . $fields[12] . $csv_separator_var;

                    $data_element = $data_element . $fields[13] . $csv_separator_var;
                    $data_element = $data_element . ($fields[13] - $p_gx_data_13_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[14] . $csv_separator_var;
                    $data_element = $data_element . ($fields[14] - $p_gx_data_14_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[15] . $csv_separator_var;
                    $data_element = $data_element . ($fields[15] - $p_gx_data_15_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[16] . $csv_separator_var;
                    $data_element = $data_element . ($fields[16] - $p_gx_data_16_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[17] . $csv_separator_var;
                    $data_element = $data_element . ($fields[17] - $p_gx_data_17_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[18] . $csv_separator_var;
                    $data_element = $data_element . ($fields[18] - $p_gx_data_18_delta_value);

                    $p_gx_data_1_delta_value = $fields[1];
                    $p_gx_data_2_delta_value = $fields[2];
                    $p_gx_data_3_delta_value = $fields[3];
                    $p_gx_data_4_delta_value = $fields[4];
                    $p_gx_data_5_delta_value = $fields[5];
                    $p_gx_data_6_delta_value = $fields[6];
                    $p_gx_data_7_delta_value = $fields[7];
                    $p_gx_data_8_delta_value = $fields[8];
                    $p_gx_data_9_delta_value = $fields[9];
                    $p_gx_data_10_delta_value = $fields[10];
                    $p_gx_data_11_delta_value = $fields[11];

                    $p_gx_data_13_delta_value = $fields[13];
                    $p_gx_data_14_delta_value = $fields[14];
                    $p_gx_data_15_delta_value = $fields[15];
                    $p_gx_data_16_delta_value = $fields[16];
                    $p_gx_data_17_delta_value = $fields[17];
                    $p_gx_data_18_delta_value = $fields[18];

                }

                push (@{$csv_gx_report{$apn}{$pcrf}}, $data_element) ;
            }

        }
    }


}

#----------------------------------------------------------------------
# Functions - save_radius_report --------------------------------------

sub save_radius_report()
{

    my $push_string = "";
    $push_string = $push_string . $p_radius_header_apn . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_server . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_time . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_1 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_1_delta . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_2 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_2_delta . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_3 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_3_delta . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_4 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_4_delta . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_5 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_header_5_delta;

	print "\n" if ($verbose_mode);

    # Open file
    my $filename = "";
    if ( $report_title ne "")
    {
        $filename = $exported_directory . "/" . $report_title . "_report_radius_" . $nano . ".csv";
    }
    else
    {
        $filename = $exported_directory . "/report_radius_" . $nano . ".csv";
    }

    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    
    # Print Header in file.
    print $fh $push_string . "\n";

    # Export records
    foreach my $apn (sort keys %csv_radius_report)
    {
        foreach my $server (sort keys %{ $csv_radius_report{$apn} })
        {
            foreach my $data_array (@{$csv_radius_report{$apn}{$server}} )
            {
                print $fh  $apn . $csv_separator_var . $server . $csv_separator_var . $data_array . "\n";
            }
        }
    }

    close $fh;

}

#----------------------------------------------------------------------
# Functions - calculate_delta_radius ----------------------------------

sub calculate_delta_radius()
{

    # Export records
    foreach my $apn (sort keys %csv_radius_report)
    {
        foreach my $server (sort keys %{ $csv_radius_report{$apn} })
        {

            for my $i (0 .. $#{$csv_radius_report{$apn}{$server}})
            {

                my $data_element = shift @{$csv_radius_report{$apn}{$server}};
                my @fields = (split '\|', $data_element);

                if ($i eq 0)
                {

                    $data_element = $fields[0] . $csv_separator_var;
                    $data_element = $data_element . $fields[1] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[2] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[3] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[4] . $csv_separator_var;
                    $data_element = $data_element . "0" . $csv_separator_var;
                    $data_element = $data_element . $fields[5] . $csv_separator_var;
                    $data_element = $data_element . "0" ;

                    $p_radius_data_1_delta_value = $fields[1];
                    $p_radius_data_2_delta_value = $fields[2];
                    $p_radius_data_3_delta_value = $fields[3];
                    $p_radius_data_4_delta_value = $fields[4];
                    $p_radius_data_5_delta_value = $fields[5];

                }
                else
                {

                    $data_element = $fields[0] . $csv_separator_var;
                    $data_element = $data_element . $fields[1] . $csv_separator_var;
                    $data_element = $data_element . ($fields[1] - $p_radius_data_1_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[2] . $csv_separator_var;
                    $data_element = $data_element . ($fields[2] - $p_radius_data_2_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[3] . $csv_separator_var;
                    $data_element = $data_element . ($fields[3] - $p_radius_data_3_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[4] . $csv_separator_var;
                    $data_element = $data_element . ($fields[4] - $p_radius_data_4_delta_value) . $csv_separator_var;
                    $data_element = $data_element . $fields[5] . $csv_separator_var;
                    $data_element = $data_element . ($fields[5] - $p_radius_data_5_delta_value);

                    $p_radius_data_1_delta_value = $fields[1];
                    $p_radius_data_2_delta_value = $fields[2];
                    $p_radius_data_3_delta_value = $fields[3];
                    $p_radius_data_4_delta_value = $fields[4];
                    $p_radius_data_5_delta_value = $fields[5];

                }

                push (@{$csv_radius_report{$apn}{$server}}, $data_element) ;
            }

        }
    }

}


#----------------------------------------------------------------------
# Functions - gx_sub_array --------------------------------------------

sub gx_sub_array()
{
    my ($data_array_2, $push_string) = @_;

    # CSV data
    $p_gx_data_1 = "";
    $p_gx_data_2 = "";
    $p_gx_data_3 = "";
    $p_gx_data_4 = "";
    $p_gx_data_5 = "";
    $p_gx_data_6 = "";
    $p_gx_data_7 = "";
    $p_gx_data_8 = "";
    $p_gx_data_9 = "";
    $p_gx_data_10 = "";
    $p_gx_data_11 = "";
    $p_gx_data_12 = "";
    $p_gx_data_13 = "";
    $p_gx_data_14 = "";
    $p_gx_data_15 = "";
    $p_gx_data_16 = "";
    $p_gx_data_17 = "";
    $p_gx_data_18 = "";

    foreach my $data_array_3 (@{ $data_array_2->{'r'} } )
    {
        switch ($data_array_3->{'p'})
        {
            case 1
            { 
                print ("======> " . "ccr-initial-sent => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_1 = $data_array_3->{'content'};
            }
            case 2
            { 
                print ("======> " . "ccr-initial-failed => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_2 = $data_array_3->{'content'};
            }
            case 3
            { 
                print ("======> " . "ccr-update-sent => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_3 = $data_array_3->{'content'};
            }
            case 4
            { 
                print ("======> " . "ccr-update-failed => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_4 = $data_array_3->{'content'};
            }
            case 5
            { 
                print ("======> " . "ccr-termination-sent => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_5 = $data_array_3->{'content'};
            }
            case 6
            { 
                print ("======> " . "ccr-termination-failed => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_6 = $data_array_3->{'content'};
            }
            case 7
            { 
                print ("======> " . "user-service-denied => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_7 = $data_array_3->{'content'};
            }
            case 8
            { 
                print ("======> " . "user-unknown => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_8 = $data_array_3->{'content'};
            }
            case 9
            { 
                print ("======> " . "authorization-failure => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_9 = $data_array_3->{'content'};
            }
            case 10
            { 
                print ("======> " . "authentication-failure => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_10 = $data_array_3->{'content'};
            }
            case 11
            { 
                print ("======> " . "unknown-session-id => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_11 = $data_array_3->{'content'};
            }
            case 12
            { 
                print ("======> " . "active-gx-sessions => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_12 = $data_array_3->{'content'};
            }
            case 13
            { 
                print ("======> " . "pending-transaction-received => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_13 = $data_array_3->{'content'};
            }
            case 14
            { 
                print ("======> " . "pending-transaction-sent => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_14 = $data_array_3->{'content'};
            }
            case 15
            { 
                print ("======> " . "pending-transaction-loop-termination => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_15 = $data_array_3->{'content'};
            }
            case 16
            { 
                print ("======> " . "temporarily-offline-sessions => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_16 = $data_array_3->{'content'};
            }
            case 17
            { 
                print ("======> " . "permanently-offline-sessions => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_17 = $data_array_3->{'content'};
            }
            case 18
            { 
                print ("======> " . "rar-received-nt => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_gx_data_18 = $data_array_3->{'content'};
            }
        }
    }

    $push_string = $push_string . $p_gx_data_1 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_2 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_3 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_4 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_5 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_6 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_7 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_8 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_8 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_10 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_11 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_12 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_13 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_14 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_15 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_16 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_17 . $csv_separator_var ;
    $push_string = $push_string . $p_gx_data_18;
    
    return $push_string;
}

#----------------------------------------------------------------------
# Functions - radius_sub_array ----------------------------------------

sub radius_sub_array()
{
    my ($data_array_2, $push_string) = @_;

    # CSV data
    $p_radius_data_1 = "";
    $p_radius_data_2 = "";
    $p_radius_data_3 = "";
    $p_radius_data_4 = "";
    $p_radius_data_5 = "";

    foreach my $data_array_3 (@{ $data_array_2->{'r'} } )
    {
        switch ($data_array_3->{'p'})
        {
            case 1
            {
                print ("======> " . "accounting-requests => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_radius_data_1 = $data_array_3->{'content'};
            }
            case 2
            {
                print ("======> " . "accounting-responses => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_radius_data_2 = $data_array_3->{'content'};
            }
            case 3
            {
                print ("======> " . "accounting-request-timeouts => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_radius_data_3 = $data_array_3->{'content'};
            }
            case 4
            {
                print ("======> " . "server-accounting-request-retransmits => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_radius_data_4 = $data_array_3->{'content'};
            }
            case 5
            {
                print ("======> " . "invalid-authenticators => " . $data_array_3->{'content'} . " \n") if ($verbose_mode);
                $p_radius_data_5 = $data_array_3->{'content'};
            }
        }
    }

    $push_string = $push_string . $p_radius_data_1 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_data_2 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_data_3 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_data_4 . $csv_separator_var ;
    $push_string = $push_string . $p_radius_data_5;

    return $push_string;
}

#----------------------------------------------------------------------
# Functions - pgw_apn -------------------------------------------------

sub pgw_apn()
{
    my ($filename) = @_;

    print "\nParsing file: $filename\n" if ($verbose_mode);

    my $parser = new XML::Simple;
    my $dom = $parser->XMLin($filename);
    my $found_gx_info = false;
    my $found_radius_info = false;

    my $push_string = "";

    foreach my $data_array ( @{ $dom->{'measData'}->{'measInfo'} } )
    {
        

        if ( ($data_array->{'measInfoId'} eq "ggsn-apn-radius-acct-servers-stats") and $get_pgw_apn_radius )
        {
            print ("==> ggsn-apn-radius-acct-servers-stats:\n") if ($verbose_mode);
            $found_radius_info = true;
            my $granPeriod = $data_array->{'granPeriod'}->{'endTime'};
            
            foreach my $data_array_2 ( @{ $data_array->{'measValue'} } )
            {

                my $apn = (split '/', $data_array_2->{'measObjLdn'})[3];
                $apn = (split '=',$apn)[1];
                $apn =~ tr/]//d;

                my $server = (split '/', $data_array_2->{'measObjLdn'})[6];
                $server = (split '=',$server)[1];
                $server =~ tr/]//d;

                print ("====> End period time: " . $granPeriod . "\n") if ($verbose_mode);
                print ("====> APN: " . $apn . " \n") if ($verbose_mode);
                print ("====> Server: " . $server . " \n") if ($verbose_mode);

                $radius_count = $radius_count + 1;

                if (($radius_apnlist eq "all") and ($radius_serverlist eq "all"))
                {
                    print "No APN or Server Filtered\n\n" if ($verbose_mode);
                    $push_string = "";
                    # Push time
                    $push_string = $push_string . $granPeriod . $csv_separator_var ;
                    # Push data
                    $push_string = &radius_sub_array($data_array_2, $push_string);
                    push (@{$csv_radius_report{$apn}{$server}}, $push_string);
                }
                elsif (($radius_apnlist eq "all") and not ($radius_serverlist eq "all"))
                {
                    print "No APN Filtered, Server filtered\n\n" if ($verbose_mode);
                    if ( grep(/^$server$/i, @radius_serverlist_array) ) 
                    {
                        $push_string = "";
                        # Push time
                        $push_string = $push_string . $granPeriod . $csv_separator_var ;
                        # Push data
                        $push_string = &radius_sub_array($data_array_2, $push_string);
                        push (@{$csv_radius_report{$apn}{$server}}, $push_string);
                    }
                }
                if (not ($radius_apnlist eq "all") and ($radius_serverlist eq "all"))
                {
                    print "No Server Filtered, APN Filtered\n\n" if ($verbose_mode);
                    if ( grep(/^$apn$/i, @radius_apnlist_array) ) 
                    {
                        $push_string = "";
                        # Push time
                        $push_string = $push_string . $granPeriod . $csv_separator_var ;
                        # Push data
                        $push_string = &radius_sub_array($data_array_2, $push_string);
                        push (@{$csv_radius_report{$apn}{$server}}, $push_string);
                    }
                }
                else
                {
                    print "Server and APN Filtered\n\n" if ($verbose_mode);
                    if ( (grep(/^$apn$/i, @radius_apnlist_array)) and (grep(/^$server$/i, @radius_serverlist_array)) )
                    {
                        $push_string = "";
                        # Push time
                        $push_string = $push_string . $granPeriod . $csv_separator_var ;
                        # Push data
                        $push_string = &radius_sub_array($data_array_2, $push_string);
                        push (@{$csv_radius_report{$apn}{$server}}, $push_string);
                    }
                }

                print ("\n") if ($verbose_mode);
            }
        }

        if ( ($data_array->{'measInfoId'} eq "pgw-apn-gx") and $get_pgw_apn_gx )
        {
            print ("==> pgw-apn-gx:\n") if ($verbose_mode);
            $found_gx_info = true;
            my $granPeriod = $data_array->{'granPeriod'}->{'endTime'};
            
            foreach my $data_array_2 ( @{ $data_array->{'measValue'} } )
            {

                my $apn = (split '/', $data_array_2->{'measObjLdn'})[3];
                $apn = (split '=',$apn)[1];
                $apn =~ tr/]//d;

                my $pcrf = (split '/', $data_array_2->{'measObjLdn'})[6];
                $pcrf = (split '=',$pcrf)[1];
                $pcrf =~ tr/]//d;
                
                print ("====> End period time: " . $granPeriod . "\n") if ($verbose_mode);
                print ("====> APN: " . $apn . " \n") if ($verbose_mode);
                print ("====> PCRF: " . $pcrf . " \n") if ($verbose_mode);
                $apn_count = $apn_count + 1;


                if ( ($gx_apnlist eq "all") and ($gx_pcrflist eq "all") )
                {
                    print "No APN or PCRF Filtered\n\n" if ($verbose_mode);
                    $push_string = "";
                    # Push time
                    $push_string = $push_string . $granPeriod . $csv_separator_var ;
                    # Push data
                    $push_string = &gx_sub_array($data_array_2, $push_string);
                    push (@{$csv_gx_report{$apn}{$pcrf}}, $push_string);
                }
                elsif ( ($gx_apnlist eq "all") and not ($gx_pcrflist eq "all") )
                {
                    print "No APN Filtered, PCRF Filtered\n\n" if ($verbose_mode);
                    # $value can be any regex. be safe
                    if ( grep(/^$pcrf$/i, @gx_pcrflist_array) ) 
                    {
                        $push_string = "";
                        # Push time
                        $push_string = $push_string . $granPeriod . $csv_separator_var ;
                        # Push data
                        $push_string = &gx_sub_array($data_array_2, $push_string);
                        push (@{$csv_gx_report{$apn}{$pcrf}}, $push_string);
                    }
                }
                elsif ( not ($gx_apnlist eq "all") and ($gx_pcrflist eq "all") )
                {
                    print "No PCRF Filtered, APN Filtered\n\n" if ($verbose_mode);
                    # $value can be any regex. be safe
                    if ( grep(/^$apn$/i, @gx_apnlist_array) ) 
                    {
                        $push_string = "";
                        # Push time
                        $push_string = $push_string . $granPeriod . $csv_separator_var ;
                        # Push data
                        $push_string = &gx_sub_array($data_array_2, $push_string);
                        push (@{$csv_gx_report{$apn}{$pcrf}}, $push_string);
                    }
                }
                else
                {
                    print "APN and PCRF Filtered\n\n" if ($verbose_mode);
                    # $value can be any regex. be safe
                    if ( (grep(/^$apn$/i, @gx_apnlist_array)) and (grep(/^$pcrf$/i, @gx_pcrflist_array)) ) 
                    {
                        $push_string = "";
                        # Push time
                        $push_string = $push_string . $granPeriod . $csv_separator_var ;
                        # Push data
                        $push_string = &gx_sub_array($data_array_2, $push_string);
                        push (@{$csv_gx_report{$apn}{$pcrf}}, $push_string);
                    }
                }
                print ("\n") if ($verbose_mode);
            }
        }
    }

    if ( (not $found_gx_info) and $get_pgw_apn_gx)
    {
        print ("==> pgw-apn-gx info not found.\n") if ($verbose_mode);
    }

    if ( (not $found_radius_info) and $get_pgw_apn_radius)
    {
        print ("==> pgw-apn-radius info not found.\n") if ($verbose_mode);
    }
}


#----------------------------------------------------------------------
# Functions - find_xml_files_and_export -------------------------------

sub find_xml_files_and_export()
{

    my ($operation) = @_;
    opendir(DIR, $pm_log_directory) or die $!;

    print "\nParsing files ...\n\n";

    foreach( sort { $a cmp $b } readdir(DIR))
    {
        $files_count = $files_count + 1;
        # Use a regular expression to ignore files beginning with a period
        next if ($_ =~ m/^\./);
        # Use a regular expression to get xml files
        next unless ($_ =~ m/\.xml$/);
        my $fullPathfile = $pm_log_directory . '/'. $_;
        if ($operation eq "get_pgw")
        {
            &pgw_apn($fullPathfile);
        }
    }
    closedir(DIR);
    # Remove directory information . and  ..
    $files_count = $files_count - 2;
    
    if ($get_pgw_apn_gx)
    {
        print ("\nCalculate delta values ... pgw-apn-gx.\n");
        calculate_delta_gx();
        print ("\nSaving ... pgw-apn-gx report.\n");
        save_gx_report();
        save_gx_plot();
    }

    if ($get_pgw_apn_radius)
    {
        print ("\nCalculate delta values ... pgw-apn-radius.\n");
        calculate_delta_radius();
        print ("\nSaving ... pgw-apn-radius report.\n");
        save_radius_report();
        save_radius_plot();
    }
}

#----------------------------------------------------------------------
# Main - Begin --------------------------------------------------------

my $start_run = time();

# Get ARGV list and Parse it
get_arg();

# Check script arguments.
if ($#ARGV < 0)
{
	print_help();
}
else
{
	switch ($ARGV[0])
	{
		case "--print_help"
		{
			print_help();
		}
		case "--print_version"
		{
			print_version();
		}
		else
		{
            if ($get_pgw_apn_gx or $get_pgw_apn_radius)
            {
                print_version();
                # Parse Gx Statistics
                &find_xml_files_and_export("get_pgw");
            }
            else
            {
                print_help();
            }
		}
	}
}

my $end_run = time();
my $run_time = $end_run - $start_run;
# Print script execution time and statistics
print "\n----------------------------------------------------------------\n";
print "Final Report: ---------------------------------------------------\n";
print "Date: $nano ---------------------------------------------------\n";
print "Execution time: $run_time seconds\n";
if ($get_pgw_apn_gx)
{
    print "pgw-apn-gx Statistics: Parsed $files_count files and $apn_count APN+Server.\n";
}
if ($get_pgw_apn_radius)
{
    print "pgw-apn-radius Statistics: Parsed $files_count files and $radius_count APN+Server.\n";
}
print "\n";

exit 0;

#----------------------------------------------------------------------
# Main - End ----------------------------------------------------------
#----------------------------------------------------------------------
