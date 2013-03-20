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
my $tp = $gCGI->param('tp');
my $filter = $gCGI->param('fi');
return ($tp,$filter);
}

#Obtention des 5 plus gros groupes
sub getHost($){

	my $filter = $_[0];
	if($filter ne ""){
		$filter =~ s/'/\\'/g;
		my $requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL AND (`host_address` REGEXP '".$filter."' OR `host_name` REGEXP '".$filter."' OR `host_alias` REGEXP '".$filter."' OR `Name` REGEXP '".$filter."' OR `group_name` REGEXP '".$filter."') 
					ORDER BY `host_name` LIMIT 0,40";
	
	
		my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
		my $sth = $sdbh->prepare($requete);
		$sth->execute();
		my $html = '';
		while( my ($id,$hname,$gname,$add,$sta,$halias,$tname) = $sth->fetchrow_array ){
			my $bg ="";
			if (!defined $gname){ $gname = ""};
			if (!defined $tname){ $tname = ""};
			if (!defined $halias){ $halias = ""};
			if($sta == 1){
				$bg = "bg-color-green";
			}
			elsif($sta == 0){
				$bg = "bg-color-red";
			}
			elsif($sta == 2){
				$bg = "bg-color-grey";
			}
			$html=$html.'
				<a href="/host/show/'.$id.'">
					<div class="tile '.$bg.'">
						<div class="tile-content">
							<h4>'.$hname.'</h4>
							<h5>Group : '.$gname.'</h5><h5>Type : '.$tname.'</h5><h5>Address: '.$add.'</h5><h5>Alias: '.$halias.'</h5>
						</div>
					</div>
				</a>';
		}

		print $html;
	}	
	
}


#Obtention des  groupes
sub getGroup($){
	my $filter = $_[0];
	my $bg ="";

	if($filter ne ""){
		$filter =~ s/'/\\'/g;
		my $requete = "SELECT  `id`,`group_name`
					FROM  `Host_Group` 
					WHERE  `group_name` REGEXP '".$filter."'";
	
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
	
	my ($tp,$filter)=get_params($queryCGI);
	if(defined $tp){
		if( $tp eq "host"){
			if(!defined $filter){$filter = "";}
			getHost($filter);
		}
		elsif($tp eq "group"){
			if(!defined $filter){$filter = "";}
			getGroup($filter);
		}
	}


}

main;
