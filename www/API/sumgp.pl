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

sub getAllSubGroup($);

sub getAllSubGroup($){
	my $subParent = $_[0];
	my $up=0;
	my $down=0;
	my $unre=0;
	my $gpname="";
	
	#traitement des sous-groupes
	my $requete = "SELECT  `id` 
					FROM  `Host_Group` 
					WHERE  `parent_group`='".$subParent."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
	$sth->execute();
	while( my $id = $sth->fetchrow_array ){
		my ($tempup,$tempunre,$tempdown) = getAllSubGroup($id);
		$up=$up+$tempup;
		$unre=$unre+$tempdown;
		$down=$down+$tempdown;
	}
	
	#Traitements des host du group courant
	$requete = "	SELECT  COUNT( * ), `host_status`
					FROM  `Host` 
					WHERE  `host_group`='".$subParent."'
					GROUP BY `host_status`" ;
	$sth = $sdbh->prepare($requete);
	$sth->execute();
	while( my ($count,$stat) = $sth->fetchrow_array ){
		if($stat == 1){
			$up=$up+$count;
		}
		elsif($stat == 2){
			$unre=$unre+$count;
		}
		else{
			$down=$down+$count;
		}
	}
	$sth->finish;
	$sdbh->disconnect;
	
	return ($up,$unre,$down);

}



#Obtention des 5 plus gros groupes
sub getGroup(){

	my $requete = "SELECT Host_Group.`id` ,  `group_name`
					FROM  `Host_Group` 
					LEFT OUTER JOIN  `Host` ON Host_Group.id = Host.host_group
					WHERE  `parent_group` IS NULL 
					GROUP BY  `group_name` 
					ORDER BY COUNT( * ) DESC
					LIMIT 0 , 5";

	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $i=0;
	my $json = '{';
	while( my ($id,$gname) = $sth->fetchrow_array ){
		my ($up,$unre,$down) = getAllSubGroup($id);
		if ($i == 0){
			$json = $json.'"group'.$i.'":'.'{ "name":"'.$gname.'","up":"'.$up.'","down":"'.$down.'","unre":"'.$unre.'","id":"'.$id.'" }';
		}
		else{
			$json = $json.', "group'.$i.'":'.'{ "name":"'.$gname.'","up":"'.$up.'","down":"'.$down.'","unre":"'.$unre.'","id":"'.$id.'" }';
		}
		$i++;
	}
	$sth->finish;
	$sdbh->disconnect;
	$json = $json.'}';
	print $json;
		
	
}



sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header('application/json');;
	getGroup;
	


}

main;
