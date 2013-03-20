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
my $tc; #the group/host type to be child
my $ckey; #api key
my $nap; #name parent
my $nac; #name child
my $idp; #id parent
my $idc; #id child
my $bcp; #alias parent
my $bcc; #alias child

sub get_params;
sub get_group_idwN;
sub get_host_idwN;
sub get_host_idwA;

#Predeclaration of function to link a group to another
sub linkGItoGI;

#Predeclaration of function to link a host to another
sub linkHItoHI;

#predeclaration of function to add an host to another
sub linkHItoGI;

sub main;

sub get_params{
#GET mains args for statistic generation
#---------------------------------------------

#apikey
$ckey = $queryCGI->param('key');

#tp
$tp = $queryCGI->param('tp');

#tc
$tc = $queryCGI->param('tc');

#idp
$idp = $queryCGI->param('idp');

#idc
$idc = $queryCGI->param('idc');

#nap
$nap = $queryCGI->param('nap');
$nap =~ s/'/\\'/g;

#nac
$nac = $queryCGI->param('nac');
$nac =~ s/'/\\'/g;

#id
$bcp = $queryCGI->param('bcp');

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

sub linkGItoGI{
	my $req = "UPDATE `Host_Group` SET `parent_group`='".$idp."' WHERE `id`='".$idc."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
};

sub linkHItoHI{
	my $req = "UPDATE `Host` SET `parent_host`='".$idp."' WHERE `id`='".$idc."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
};

sub linkHItoGI{
	my $req = "UPDATE `Host` SET `host_group`='".$idp."' WHERE `id`='".$idc."'";
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
	if(defined $tp && defined $ckey && defined $tc  && $ckey == $apikey && $tp ne $tc){
		if ( $tp eq "host" && $tc eq "group"){
			print '0';
		}
		#normal case
		elsif( $tp eq "group" && $tc eq "host"){
			if ( defined $idp){
				if ( defined $idc ){
					linkHItoGI;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					linkHItoGI;
				}
				elsif (defined $bcc){
					$idc = get_host_idwA($bcc);
					linkHItoGI;
				}
				else{
				print '0';
				}
			}
			elsif ( defined $nap){
				$idp = get_group_idwN($nap);
				if ( defined $idc ){
					linkHItoGI;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					linkHItoGI;
				}
				elsif (defined $bcc){
					$idc = get_host_idwA($bcc);
					linkHItoGI;
				}
				else{
				print '0';
				}
				
			}
			elsif (defined $bcp){
				print '0'; #group has no alias
			}
		}
		else{
			print '0';
		}
		
	}
	elsif ( (defined $tp && defined $ckey && $ckey == $apikey) || (defined $tp && defined $ckey && defined $tp && $tp eq $tc  && $ckey == $apikey)  ){
		#if link are only inter-group
		if ( $tp eq "group" ){
			if ( defined $idp){
				if ( defined $idc ){
					linkGItoGI;
				}
				elsif ( defined $nac){
					$idc = get_group_idwN($nac);
					linkGItoGI;
				}
				else{
					print '0';
				}
			}
			elsif ( defined $nap){
				$idp = get_group_idwN($nap);
				if ( defined $idc ){
					linkGItoGI;
				}
				elsif ( defined $nac){
					$idc = get_group_idwN($nac);
					linkGItoGI;
				}
				else{
					print '0';
				}
				
			}
			elsif (defined $bcp){
				print '0'; #group has no alias
			}
		}
		#end of inter-group link
		#begin of inter-host link
		elsif ( $tp eq "host"){
			if ( defined $idp){
				if ( defined $idc ){
					linkHItoHI;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					linkHItoHI;
				}
				elsif (defined $bcc){
					$idc = get_host_idwA($bcc);
					linkHItoHI;
				}
				else{
				print '0';
				}
			}
			elsif ( defined $nap){
				$idp = get_host_idwN($nap);
				if ( defined $idc ){
					linkHItoHI;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					linkHItoHI;
				}
				elsif (defined $bcc){
					$idc = get_host_idwA($bcc);
					linkHItoHI;
				}
				else{
				print '0';
				}
				
			}
			elsif (defined $bcp){
				$idp = get_host_idwA($bcp);
				if ( defined $idc ){
					linkHItoHI;
				}
				elsif ( defined $nac){
					$idc = get_host_idwN($nac);
					linkHItoHI;
				}
				elsif (defined $bcc){
					$idc = get_host_idwA($bcc);
					linkHItoHI;
				}
				else{
				print '0';
				}
			}
			else{
			print '0';
			}
			
		}
		#end of inter-host link
		else{
			print 'Bad arguments';
		}
	
	}
	#End of inter-host or inter group link
	
	else{
		print 'incorrect key or missing arguments';
	}
}

main;

