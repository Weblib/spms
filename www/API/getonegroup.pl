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

#create a json with summary infomation for the group
sub getSumGroup($){
	my $gpid=$_[0];
	my $requete = "SELECT  `group_name` 
					FROM  `Host_Group` 
					WHERE  `id`='".$gpid."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
	$sth->execute();
	my $gpname = $sth->fetchrow_array;
	my ($up,$down,$unre) = getAllSubGroup($gpid);
	print '{ "name":"'.$gpname.'","up":"'.$up.'","down":"'.$down.'","unre":"'.$unre.'" }';
}

sub getSubGroup($){
	my $gpid = $_[0];
	my $requete = "SELECT  `id`,`group_name`
					FROM  `Host_Group` 
					WHERE  `parent_group`='".$gpid."'";

	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $html = '';
	while( my ($id,$gname) = $sth->fetchrow_array ){
		my ($up,$down,$unre) = getAllSubGroup($id);
		$html=$html.'
				<a href="/group/show/'.$id.'">
					<div class="tile bg-color-blue">
						<div class="tile-content">
							<h4>'.$gname.'</h4>
							<h5>Host : '.($up+$down+$unre).'</h5><h5>Host UP : '.$up.'</h5><h5>Host down: '.$down.'</h5>
						</div>
					</div>
				</a>';
	}
	$sth->finish;
	$sdbh->disconnect;
	print $html;
		
	
}

sub getParGroup($){
	my $gpid = $_[0];
	my $requete = "SELECT  `id`,`group_name`
					FROM  `Host_Group` 
					WHERE  `id`=(SELECT `parent_group` FROM `Host_Group` WHERE `id`='".$gpid."')";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my ($id,$gname) = $sth->fetchrow_array;
	my $html = '';
	if(defined $id){
	my ($up,$down,$unre) = getAllSubGroup($id);
		$html=$html.'
				<h2>Parent Group</h2>
				<a href="/group/show/'.$id.'">
					<div class="tile bg-color-blue">
						<div class="tile-content">
							<h4>'.$gname.'</h4>
							<h5>Host : '.($up+$down+$unre).'</h5><h5>Host UP : '.$up.'</h5><h5>Host down: '.$down.'</h5>
						</div>
					</div>
				</a>';
	}
	$sth->finish;
	$sdbh->disconnect;
	print $html;
		
	
}

#Aggregate sub groupinfomation.
sub getAllSubGroup($){
	my $subParent = $_[0];
	my $up=0;
	my $down=0;
	my $unre=0;
	
	#traitement des sous-groupes
	my $requete = "SELECT  `id` 
					FROM  `Host_Group` 
					WHERE  `parent_group`='".$subParent."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
	$sth->execute();
	while( my $id = $sth->fetchrow_array ){
		my ($tempup,$tempdown,$tempunre) = getAllSubGroup($id);
			$up += $tempup;
			$down += $tempdown;
			$unre += $tempunre
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
			$up +=$count;
		}elsif($stat == 2) {
			$unre += $count;
		}
		elsif($stat == 0) {
			$down += $count;
		}
	}
	$sth->finish;
	$sdbh->disconnect;
	
	return ($up,$down,$unre);
}


#Obtention des host dépendant
sub getHost($$){
	my $limit = "LIMIT 0,39";
	my $gpid=$_[0];
	my $filter = $_[1];
	my $requete = "";
	if (defined $filter && $filter ne ""){
	$filter =~ s/'/\\'/g;
	$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL  AND  `host_group`='".$gpid."' AND `host_status`!=3 AND `host_name` REGEXP '".$filter."'
					ORDER BY `host_name` ".$limit;
	}else{
		$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL  AND  `host_group`='".$gpid."' AND `host_status`!='3'
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
	
	my ($gpid,$info,$filter)=get_params($queryCGI);
	if(defined $gpid && defined $info){ 
		if ($info eq "glo")
		{
		#For global info
		print $queryCGI->header('application/json');
			getSumGroup($gpid);
		}
		#for sub group
		elsif ($info eq "sgp")
		{
			print $queryCGI->header();
			getSubGroup($gpid);
		}
		#for sub host
		elsif ($info eq "sho")
		{
			print $queryCGI->header();
			getHost($gpid,$filter);
		}
		elsif ($info eq "par")
		{
			print $queryCGI->header();
			getParGroup($gpid);
		}
	
	}

}

main;
