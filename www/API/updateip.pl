#!/usr/bin/perl
#
use strict;
use DBI;
use POSIX;
use AppConfig qw(:expand :argcount);
use CGI;

my $config = AppConfig->new("dbHost"       => {ARGCOUNT => ARGCOUNT_ONE},
                            "dbName"  => {ARGCOUNT => ARGCOUNT_ONE},
                            "dbUser"    => {ARGCOUNT => ARGCOUNT_ONE},
                            "dbPass"=> {ARGCOUNT => ARGCOUNT_ONE},
                            "threadNumber"=> {ARGCOUNT => ARGCOUNT_ONE},
							"pidPath"	=> {ARGCOUNT => ARGCOUNT_ONE},
							"logPath"	=> {ARGCOUNT => ARGCOUNT_ONE},
							"logging"	=> {ARGCOUNT => ARGCOUNT_ONE},
							"apikey"	=> {ARGCOUNT => ARGCOUNT_ONE},
							"periodReport" => {ARGCOUNT => ARGCOUNT_ONE}
							);
 
#Lecture du fichier de configuration
$config->file('/etc/spms/spms.conf');

my $logging = $config->logging();                                  # 1= logging is on
my $dbHost = $config->dbHost();                       
my $dbName = $config->dbName();
my $dbUser = $config->dbUser();
my $dbPass = $config->dbPass();
my $apikey = $config->apikey();
my $sdsn = "DBI:mysql:database=$dbName;host=$dbHost";


#data collected
my $queryCGI = CGI->new;
my $host_name;
my $barCode;
my $key;
my $ip;
my $tp;

sub get_params;
sub insert;
sub main;

sub get_params{
#GET mains args for statistic generation
#---------------------------------------------
#Period of stat generation

#barcode of device
$barCode = $queryCGI->param('bc');

#barcode of device
$key = $queryCGI->param('key');

#ip : of device
$ip = $queryCGI->param('ip');

}

sub updateHost{
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $requete = "UPDATE `Host` SET `host_address`='".$ip."' WHERE `host_alias`='".$barCode."'";
    my $sth = $sdbh->prepare($requete);
    $sth->execute();
	$sth->finish();
	$sdbh->disconnect;
}

sub main{
	print $queryCGI->header;
	get_params;

	if ( (defined $key) && (defined $ip) && (defined $barCode) && ($key eq $apikey) )	{
			updateHost;
	}
}

main;
