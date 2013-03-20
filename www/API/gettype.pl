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
my $filter = $gCGI->param('fi');
return $filter;
}


#recup des infos d'un Type
sub getTypeSum($$){
	my $tid = $_[0];
	my $nup = 0;
	my $ndown = 0;
	my $nunre = 0;

	my $requete = "SELECT COUNT(*),`host_status`
				FROM `Host` 
				WHERE `host_type`='".$tid."' 
				AND `host_address` IS NOT NULL 
				GROUP BY `host_status`";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute;
	while ( my ($numb,$stat) = $sth->fetchrow_array ){
		if($stat == 1){
			$nup += $numb;
		}
		elsif($stat == 2){
			$nunre += $numb;
		}
		else{
			$ndown += $numb;
		}
	
	}
	return ($nup,$ndown,$nunre);
}

#Obtention des 5 plus gros groupes
sub getType($){
	my $fi=$_[0];
	my $requete;
	if ( $fi ne ""){
		$requete = " SELECT  `Host_Type`.`id` ,  `Name` 
					FROM  `Host_Type` 
					LEFT OUTER JOIN  `Host` ON  `Host`.`host_type` =  `Host_Type`.`id`
					WHERE `Name` REGEXP '".$fi."'
					GROUP BY  `host_type` 
					ORDER BY COUNT( * ) DESC ";
	}else{
	$requete = " SELECT  `Host_Type`.`id` ,  `Name` 
					FROM  `Host_Type` 
					LEFT OUTER JOIN  `Host` ON  `Host`.`host_type` =  `Host_Type`.`id` 
					GROUP BY  `host_type` 
					ORDER BY COUNT( * ) DESC ";
	}
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $html='';
	while( my ($ht,$tname) = $sth->fetchrow_array){
		my ($nup,$ndown,$nunre) = getTypeSum($ht,$fi);
		$html=$html.'
				<a href="/type/show/'.$ht.'">
						<div class="tile bg-color-blue">
						<div class="tile-content">
							<h4>'.$tname.'</h4>
							<h5>Host : '.($nup+$ndown+$nunre).'</h5><h5>Host UP : '.$nup.'</h5><h5>Host down: '.$ndown.'</h5>
						</div>
					</div>
				</a>';
	}

	print $html;
		
	
}




sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header();
	my $fi = get_params($queryCGI);
	getType($fi);
	


}

main;
