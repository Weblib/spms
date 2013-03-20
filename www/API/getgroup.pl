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


sub get_params($){
my $gCGI = $_[0];
#GET mains args for statistic generation
#---------------------------------------------
#Period of stat generation

#hostname of device
my $mo = $gCGI->param('mo');
my $filter = $gCGI->param('fi');
return ($mo,$filter);
}

#Obtention des  groupes
sub getGroup($$){
	my $mo = $_[0];
	my $filter = $_[1];
	my $stsc =0;
	my $bg ="";
	my $requete = "";
	

	if($filter ne ""){
		$filter =~ s/'/\\'/g;
		$requete = "SELECT  `id`,`group_name`
					FROM  `Host_Group` 
					WHERE  `group_name` REGEXP '".$filter."'";
	}
	elsif($mo eq "more"){
		$requete = "SELECT Host_Group.`id` ,  `group_name`
					FROM  `Host_Group` 
					LEFT OUTER JOIN  `Host` ON Host_Group.id = Host.host_group
					WHERE  `parent_group` IS NULL 
					GROUP BY  `group_name` 
					ORDER BY `group_name` ASC
					LIMIT 0 , 40";
	}
	else{
		$requete = "SELECT Host_Group.`id` ,  `group_name`
					FROM  `Host_Group` 
					LEFT OUTER JOIN  `Host` ON Host_Group.id = Host.host_group
					WHERE  `parent_group` IS NULL 
					GROUP BY  `group_name` 
					ORDER BY `group_name` ASC
					LIMIT 0 , 40";
	}
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $html = '';
	while( my ($id,$gname) = $sth->fetchrow_array ){
		my ($stot,$sup) = getAllSubGroup($id);
		$html=$html.'
				<a href="/group/show/'.$id.'">
					<div class="tile bg-color-blue">
						<div class="tile-content">
							<h4>'.$gname.'</h4>
							<h5>Host : '.$stot.'</h5><h5>Host UP : '.$sup.'</h5><h5>Host down: '.($stot-$sup).'</h5>
						</div>
					</div>
				</a>';
	}
	$sth->finish;
	$sdbh->disconnect;
	print $html;
		
	
}

sub getAllSubGroup($){
	my $subParent = $_[0];
	my $stot=0;
	my $sup=0;
	
	#traitement des sous-groupes
	my $requete = "SELECT  `id` 
					FROM  `Host_Group` 
					WHERE  `parent_group`='".$subParent."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
	$sth->execute();
	while( my $id = $sth->fetchrow_array ){
		my ($tempstot,$tempsup) = getAllSubGroup($id);
		$stot=$stot+$tempstot;
		$sup=$sup+$tempsup;
	}
	
	#Traitements des host du group courant
	$requete = "	SELECT  COUNT( * ), `host_status`
					FROM  `Host` 
					WHERE  `host_group`='".$subParent."'
					GROUP BY `host_status`" ;
	$sth = $sdbh->prepare($requete);
	$sth->execute();
	while( my ($count,$stat) = $sth->fetchrow_array ){
		$stot=$stot+$count;
		
		if($stat == 1){
			$sup=$sup+$count;
		}
	}
	$sth->finish;
	$sdbh->disconnect;
	
	return ($stot,$sup);
}





sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header;
	my ($mo,$filter)=get_params($queryCGI);
	if(!defined $mo){ $mo ="";}
	if(!defined $filter){$filter = "";}
	getGroup($mo,$filter);
	


}

main;
