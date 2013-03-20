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
my $tp; #the group/host type to be parent
my $tc; #the group/host type to be parent
my $nac; #name parent
my $idc; #id child
my $bcc; #alias child
my $ckey; #api key

sub get_params;
sub get_group_idwN;
sub get_host_idwN;
sub get_host_idwA;

#Predeclaration of function to link a group to another
sub unlinkG;

#Predeclaration of function to link a host to another
sub unlinkHH;

#Predeclaration of function to link a host to another
sub unlinkHG;

sub main;

sub get_params{
#GET mains args for unlinking generation
#---------------------------------------------

#apikey
$ckey = $queryCGI->param('key');

#tp
$tp = $queryCGI->param('tp');

#tc
$tc = $queryCGI->param('tc');

#idc
$idc = $queryCGI->param('idc');

#nac
$nac = $queryCGI->param('nac');
$nac =~ s/'/\\'/g;
#id
$bcc = $queryCGI->param('bcc');

}


sub get_group_idwN($){
	my $gname = $_[0];
	my $req = "SELECT `id` FROM `Host_Group` WHERE `group_name`='".$gname."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	my $id = $sth->fetchrow_array;
	$sth->finish;
	$sdbh->disconnect;
	return $id;
}

sub get_host_idwN($){
	my $hname = $_[0];
	my $req = "SELECT `id` FROM `Host` WHERE `host_name`='".$hname."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	my $id = $sth->fetchrow_array;
	$sth->finish;
	$sdbh->disconnect;
	return $id;
}

sub get_host_idwA($){
	my $halias = $_[0];
	my $req = "SELECT `id` FROM `Host` WHERE `host_alias`='".$halias."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	my $id = $sth->fetchrow_array;
	$sth->finish;
	$sdbh->disconnect;
	return $id;
}


sub unlinkGG{
	my $req = "UPDATE `Host_Group` SET `parent_group`=NULL WHERE `id`='".$idc."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
};

sub unlinkHH{
	my $req = "UPDATE `Host` SET `parent_host`=NULL WHERE `id`='".$idc."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
};

sub unlinkHG{
	my $req = "UPDATE `Host` SET `host_group`=NULL WHERE `id`='".$idc."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
};


sub main{
	print $queryCGI->header;
	get_params;
	#Begin of inter-type link (only a host to a group).
	if( defined $ckey && defined $tc  && $ckey == $apikey){
		if (defined $tp && $tp eq "host" && $tc eq "group"){
			print '0';
		}
		#normal case
		elsif( defined $tp && $tp eq "group" && $tc eq "host"){
				if ( defined $idc ){
					unlinkHG;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					unlinkHG;
				}
				elsif (defined $bcc){
					$idc = get_host_idwA($bcc);
					unlinkHG;
				}
				else{
				print '0';
				}

			}
		elsif ( $tc eq "group"){
				if ( defined $idc ){
					unlinkGG;
				}
				elsif ( defined $nac){
					$idc = get_group_idwN($nac);
					unlinkGG;
				}
				#no alias for group
				else {
					print '0';
				}
			}
		elsif ( $tc eq "host"){
				if ( defined $idc ){
					unlinkHH;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					unlinkHH;
				}
				elsif ( defined $bcc){
					$idc = get_host_idwA($bcc);
					unlinkHH;
				}
			}
		else{
			print '0';
			}
				
	}
			

		else{
			print '0';
		}
		
	}

	main;