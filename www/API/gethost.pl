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
my $st = $gCGI->param('st');
my $mo = $gCGI->param('mo');
my $filter = $gCGI->param('fi');
return ($st,$mo,$filter);
}


sub getHost($$$){

	my $sts=$_[0];
	my $mo = $_[1];
	my $filter = $_[2];
	my $stsc =0;
	my $bg ="";
	my $requete = "";
	my $limit = "LIMIT 0,40";
	
	if($sts eq "up"){
		$stsc = 1;
		$bg = "bg-color-green";

	}
	elsif($sts eq "do"){
		$stsc = 0;
		$bg = "bg-color-red";

	}
	elsif($sts eq "un"){
		$stsc = 2;
		$bg = "bg-color-grey";
		$limit = "LIMIT 0,20";
	}

	if($filter ne ""){
		$filter =~ s/'/\\'/g;
		$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL AND `host_status`='".$stsc."' AND (`host_address` REGEXP '".$filter."' OR `host_name` REGEXP '".$filter."' OR `host_alias` REGEXP '".$filter."' OR `Name` REGEXP '".$filter."' OR `group_name` REGEXP '".$filter."') 
					ORDER BY `host_name` LIMIT 0,40";
	}
	elsif($mo eq "more"){
		$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL AND `host_status`='".$stsc."'  
					ORDER BY `host_name`";
	}
	else{
		$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL AND `host_status`='".$stsc."'  
					ORDER BY `host_name` ".$limit;
	}
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $html = '';
	while( my ($id,$hname,$gname,$add,$sta,$halias,$tname) = $sth->fetchrow_array ){
		if (!defined $gname){ $gname = ""};
		if (!defined $tname){ $tname = ""};
		if (!defined $halias){ $halias = ""};
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




sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header;
	my ($st,$mo,$filter)=get_params($queryCGI);
	if(!defined $mo){ $mo ="";}
	if(!defined $filter){$filter = "";}
	getHost($st,$mo,$filter);
	


}

main;
