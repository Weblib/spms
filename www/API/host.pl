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
my $id;
my $ip;
my $tp;
my $action;
my $si;

sub get_params;
sub createHost;
sub updateWithId;
sub updateWithBarCode;
sub deleteWithId;
sub deleteWithBarCode;
sub enableWithId;
sub enableWithBarCode;
sub disableWithId;
sub disableithBarCode;
sub getUserToken;
sub main;

sub get_params{
#GET mains args for statistic generation
#---------------------------------------------

#action
$action = $queryCGI->param('act');

#apikey
$ckey = $queryCGI->param('key');

#host name of device
$host_name = $queryCGI->param('hn');
$host_name =~ s/'/\\'/g;

#barcode of device
$barCode = $queryCGI->param('bc');

#token
$id = $queryCGI->param('id');

#ip : of device
$ip = $queryCGI->param('ip');

#type of device 
$tp = $queryCGI->param('tp');
}

sub createHost{
	my $reqcorpus = "";
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
	#check of ip presence and set to null in the case of null
	if (defined $ip){
		if ($ip eq ""){
			$ip="NULL";
		}
		else{
			$ip="'".$ip."'";
		}
	}
	else{
		$ip="NULL";
	}
	if ($isalready == 0){
		#if host doesn't existe then proceed to add
		$requete = "INSERT INTO `Host` (`id`, `host_group`, `host_type`, `parent_host`, `host_name`, `host_alias`, `host_address`, `host_status`) VALUES (NULL, NULL, '".$tpn."', NULL, '".$host_name."', '".$barCode."', ".$ip.", '0')";
	}
	else{
		#if host already exist then proceed to update
		$reqcorpus = "`host_address`=".$ip;
		if(defined $host_name){
			$reqcorpus = $reqcorpus.",`host_name`='".$host_name."'";
		}
		$requete = "UPDATE `Host` SET ".$reqcorpus." WHERE `host_alias`='".$barCode."'";
	}
	$sth = $sdbh->prepare($requete);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub updateWithId{
	my $req;
	if(defined $ip && defined $host_name){
		$req = "UPDATE `Host` SET `host_address`='".$ip."',`host_name`='".$host_name."' WHERE `id`='".$id."'";
	}
	elsif (defined $ip){
		$req = "UPDATE `Host` SET `host_address`='".$ip."' WHERE `id`='".$id."'";
	}
	else{
		$req = "UPDATE `Host` SET `host_name`='".$host_name."' WHERE `id`='".$id."'";
	}
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub updateWithBarCode{
	my $req;
	if(defined $ip && defined $host_name){
		$req = "UPDATE `Host` SET `host_address`='".$ip."',`host_name`='".$host_name."' WHERE `host_alias`='".$barCode."'";
	}
	elsif (defined $ip){
		$req = "UPDATE `Host` SET `host_address`='".$ip."' WHERE `host_alias`='".$barCode."'";
	}
	else{
		$req = "UPDATE `Host` SET `host_name`='".$host_name."' WHERE `host_alias`='".$barCode."'";
	}
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub deleteWithId{
	my $req = "DELETE FROM `Host` WHERE `id`='".$id."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub deleteWithBarCode{
	my $req = "DELETE FROM `Host` WHERE `host_alias`='".$barCode."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub disableWithId{
	my $req = "UPDATE `Host` SET `host_status`='3',`host_address`= NULL WHERE `id`='".$id."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
	$sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub disableWithBarCode{
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $req = "UPDATE `Host` SET `host_status`='3',`host_address`= NULL WHERE `host_alias`='".$barCode."'";
	my $sth = $sdbh->prepare($req);
	$sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub enableWithId{
	my $req = "UPDATE `Host` SET `host_status`='0' WHERE `id`='".$id."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub enableWithBarCode{
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $req = "UPDATE `Host` SET `host_status`='0' WHERE `host_alias`='".$barCode."'";
	my $sth = $sdbh->prepare($req);
	$sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
	
}


sub main{
	print $queryCGI->header;
	get_params;

	if ( (defined $action) && (defined $ckey) && ($ckey == $apikey)){
		if ( $action eq "add" && defined $host_name && defined $barCode && defined $ip){
			createHost;
		}
		elsif ( $action eq "update" && ( defined $ip || defined $host_name)){
			#update using host_id
			if( defined $id ){
				updateWithId;
			}
			#update using host_alias (unique serial device)
			elsif ( defined $barCode){
				updateWithBarCode;
			}
		}
		elsif ( $action eq "delete" ){
			#update using host_id
			if( defined $id ){
				deleteWithId;
			}
			#update using host_alias (unique serial device)
			elsif ( defined $barCode){
				deleteWithBarCode;
			}
		}
		elsif ( $action eq "disable" ){
			#update using host_id
			if( defined $id ){
				disableWithId;
			}
			#update using host_alias (unique serial device)
			elsif ( defined $barCode){
				disableWithBarCode;
			}
		}
		elsif ( $action eq "enable" ){
			#update using host_id
			if( defined $id ){
				enableWithId;
			}
			#update using host_alias (unique serial device)
			elsif ( defined $barCode){
				enableWithBarCode;
			}
		}
		
		
	}
	else{
		print '0';
	}
}

main;

