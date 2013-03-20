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
my $gpid = $gCGI->param('id');
my $info = $gCGI->param('info');
my $filter = $gCGI->param('fi');
return ($gpid,$info,$filter);
}



#Obtention des 5 plus gros groupes
sub tpName($){
	my $tid = $_[0];
	my $requete = "SELECT `Name` FROM `Host_Type` WHERE id='$tid'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $tname = $sth->fetchrow_array;
	$sth->finish();
	$sdbh->disconnect();
	return $tname;
	
	
		
	
}

#Création du sous-json d'un groupe
sub getSumType($){
	my $tid = $_[0];
	my $tname = tpName($tid);
	my $requete = "";
	$requete = "SELECT COUNT(*) FROM `Host` WHERE `host_type`='".$tid."' AND `host_address` IS NOT NULL AND `host_status`='1'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $up = $sth->fetchrow_array;
	$requete = "SELECT COUNT(*) FROM `Host` WHERE `host_type`='".$tid."' AND `host_address` IS NOT NULL AND `host_status`='0'";
	$sth = $sdbh->prepare($requete);
	$sth->execute();
	my $down = $sth->fetchrow_array;
	$requete = "SELECT COUNT(*) FROM `Host` WHERE `host_type`='".$tid."' AND `host_address` IS NOT NULL AND `host_status`='2'";
	$sth = $sdbh->prepare($requete);
	$sth->execute();
	my $unre = $sth->fetchrow_array;
	print '{ "name":"'.$tname.'","up":"'.$up.'","down":"'.$down.'","unre":"'.$unre.'" }';
}






#Obtention des host dépendant
sub getHost($$){
	my $limit = "LIMIT 0,39";
	my $tid=$_[0];
	my $filter = $_[1];
	my $requete = "";
	if (defined $filter && $filter ne ""){
	$filter =~ s/'/\\'/g;
	$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL  AND  `host_type`='".$tid."' AND `host_status`!=3 AND (`host_name` REGEXP '".$filter."' OR `host_address` REGEXP '".$filter."' OR `host_alias` REGEXP '".$filter."' )
					ORDER BY `host_name` ".$limit;
	}else{
		$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL  AND  `host_type`='".$tid."' AND `host_status`!='3'
					ORDER BY `host_name` ".$limit;
	}
	
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $html = '';
	while( my ($id,$hname,$gname,$add,$sta,$halias,$tname) = $sth->fetchrow_array ){
		my $bg ="";
	if($sta eq "1"){
		$bg = "bg-color-green";
	}
	elsif($sta eq "0"){
		$bg = "bg-color-red";
	}
	elsif($sta eq "2"){
		$bg = "bg-color-grey";
	}
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
	
	my ($tid,$info,$filter)=get_params($queryCGI);
	if(defined $tid && defined $info){ 
		if ($info eq "glo")
		{
		#For global info
		print $queryCGI->header('application/json');
			getSumType($tid);
		}
		#for sub host
		elsif ($info eq "sho")
		{
			print $queryCGI->header();
			getHost($tid,$filter);
		}
		
	
	}

}

main;
