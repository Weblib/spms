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
my $sdsn = "DBI:mysql:database=".$dbName.";host=".$dbHost;


sub nup{
	my $requete = "";
	$requete = "SELECT COUNT(*) FROM `Host` WHERE `host_address` IS NOT NULL AND `host_status`='1'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $up = $sth->fetchrow_array;
	$requete = "SELECT COUNT(*) FROM `Host` WHERE `host_address` IS NOT NULL AND `host_status`='0'";
	$sth = $sdbh->prepare($requete);
	$sth->execute();
	my $down = $sth->fetchrow_array;
	$requete = "SELECT COUNT(*) FROM `Host` WHERE `host_address` IS NOT NULL AND `host_status`='2'";
	$sth = $sdbh->prepare($requete);
	$sth->execute();
	my $unre = $sth->fetchrow_array;
	print '{ "up":"'.$up.'","down":"'.$down.'","unre":"'.$unre.'" }';
}


sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header('application/json');;
	nup;

	


}

main;
