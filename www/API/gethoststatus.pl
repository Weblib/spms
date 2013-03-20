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


sub get_params($){
my $gCGI = $_[0];
#GET mains args for statistic generation
#---------------------------------------------
#Period of stat generation

#hostname of device
my $host_name = $gCGI->param('hn');

#barcode of device
my $barCode = $gCGI->param('bc');

#ip of device
my $ip = $gCGI->param('ip');
return ($host_name,$barCode,$ip);
}

sub getHostStatus($$){
	my $checkBy = $_[0];
	my $byWhat = $_[1];
	my $requete = "";
	my $status = 0;
	my $tpn;
	if ($checkBy eq 'bc'){
		$requete = "SELECT `host_status` FROM `Host` WHERE `host_alias`='".$byWhat."'";
	}
	elsif($checkBy eq 'ip'){
		$requete = "SELECT `host_status` FROM `Host` WHERE `host_address`='".$byWhat."'";
	}
	elsif($checkBy eq 'hn'){
		$requete = "SELECT `host_status` FROM `Host` WHERE `host_name`='".$byWhat."'";
	}
	
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	$status = $sth->fetchrow_array;
	print $status;
}


sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header;
	
	my ($host_name,$barCode,$ip)=get_params($queryCGI);

	if ( defined $barCode )	{
		getHostStatus('bc',$barCode);
	}
	elsif ( defined $ip ) {
		getHostStatus('ip',$ip);
	}
	elsif ( defined $host_name ) {
		getHostStatus('hn',$host_name);
	}


}

main;
