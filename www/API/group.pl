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
my $group_name;
my $ckey;
my $token;
my $action;
my $id;

sub get_params;
sub createGroup;
sub updateWithId;
sub deleteWithId;
sub deleteWithName;
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
$group_name = $queryCGI->param('gn');
$group_name =~ s/'/\\'/g;

#id
$id = $queryCGI->param('id');

}

sub createGroup{
	#check if host is already here
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $requete = "SELECT COUNT(*) FROM `Host_Group` WHERE `group_name`='".$group_name."'";
	my $sth = $sdbh->prepare($requete);
	$sth->execute();
	my $isalready = $sth->fetchrow_array;
	if ($isalready == 0){
		#if host doesn't existe then proceed to add
		$requete = "INSERT INTO `Host_Group` (`id`, `group_name`, `parent_group`) VALUES (NULL, '".$group_name."', NULL)";
		$sth = $sdbh->prepare($requete);
		$sth->execute();
		$sth->finish;
		$sdbh->disconnect;
		print '1';
	}
	else{
		print '0';
	}
	
}

sub updateWithId{
	my $req = "UPDATE `Host_Group` SET `group_name`='".$group_name."' WHERE `id`='".$id."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub deleteWithId{
	my $req = "DELETE FROM `Host_Group` WHERE `id`='".$id."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}

sub deleteWithName{
	my $req = "DELETE FROM `Host_Group` WHERE `group_name`='".$group_name."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($req);
    $sth->execute();
	$sth->finish;
	$sdbh->disconnect;
	print '1';
}




sub main{
	print $queryCGI->header;
	get_params;

	if ( (defined $action) && (defined $ckey)  && ($ckey == $apikey)){
		if ( $action eq "add" && defined $group_name ){
				createGroup;
		}
		elsif ( $action eq "update" && defined $id && defined $group_name){
			#update using host_id
					updateWithId;
		}
		elsif ( $action eq "delete" ){
			#delete using host_id
			if( defined $id ){
				deleteWithId;
			}
			#delete using group_name (unique serial device)
			elsif ( defined $group_name){
				deleteWithName;
			}
		}
	
	}
	else{
		print '0';
	}
}

main;

