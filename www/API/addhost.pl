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
my $ckey;
my $ip;
my $tp;

sub get_params;
sub insert;
sub main;

sub get_params{
#GET mains args for statistic generation
#---------------------------------------------
#apikey
$ckey = $queryCGI->param('key');

#barcode of device
$host_name = $queryCGI->param('hn');

#barcode of device
$barCode = $queryCGI->param('bc');

#ip : of device
$ip = $queryCGI->param('ip');

#type of device 
$tp = $queryCGI->param('tp');
}

sub insertHost{
	my $tpn;
	if ($tp eq 'ipad'){
		$tpn = 2;
	}
	elsif($tp eq 'box'){
		$tpn = 7;
	}
	elsif($tp eq 'ap'){
		$tpn = 3;
	}
	else{
		$tpn = 1;
	}
	#check if host is already here
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $requete = "SELECT COUNT(*) FROM `Host` WHERE `host_name`='".$host_name."' OR `host_alias`='".$barCode."'";
	my $sth = $sdbh->prepare($requete);
	$sth->execute();
	my $isalready = $sth->fetchrow_array;
	if ($isalready == 0){
	$requete = "INSERT INTO `Host` (`id`, `host_group`, `host_type`, `parent_host`, `host_name`, `host_alias`, `host_address`, `host_status`) VALUES (NULL, NULL, '$tpn', NULL, '$host_name', '$barCode', '$ip', '0')";
	}
	else{
	$requete = "UPDATE `Host` SET `host_address`='".$ip."',`host_name`='".$host_name."' WHERE `host_alias`='".$barCode."'";
	}
	$sth = $sdbh->prepare($requete);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub main{
	print $queryCGI->header;
	get_params;

	if ( (defined $host_name) && (defined $ip) && (defined $barCode) && (defined $ckey) )	{
		if ($ckey == $apikey){
		insertHost;
		}
	}
	else{
		print '0';
	}
}

main;

