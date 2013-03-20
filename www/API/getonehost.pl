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
my $hid = $gCGI->param('id');
my $info = $gCGI->param('info');
my $filter = $gCGI->param('fi');
return ($hid,$info,$filter);
}

#recup des infos d'un Type
sub getTypeSum($){
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

sub getHostInfo($){
	my $bg ="";
	my $hid = $_[0];
	my $requete = "SELECT  `Host`.`id` ,  `host_name` ,  `host_status` ,  `host_alias` ,  `host_address` ,  `Name` 
					FROM  `Host` 
					LEFT OUTER JOIN  `Host_Type` ON  `Host`.`host_type` =  `Host_Type`.`id` 
					WHERE  `Host`.`id` =  '".$hid."'";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my ($id,$hname,$sta,$halias,$hip,$htp) = $sth->fetchrow_array;
	my $json = '';
	my $sts ='';
	if (!defined $hname){ $hname = ""}
	if (!defined $halias){ $halias = ""}
	if (!defined $htp){ $htp=""}
	if ( defined $id){
		if ($sta ==1){
			$sts = "Up";
		}elsif($sta == 0){
			$sts = "Down";
		}elsif($sta == 2){
			$sts = "Unreachable";
		}
		$json='{ "id":"'.$id.'","name":"'.$hname.'","stat":"'.$sts.'","halias":"'.$halias.'","type":"'.$htp.'","hadd":"'.$hip.'" }';
	}
	$sth->finish;
	$sdbh->disconnect;
	print $json;
	
	
}


sub getParGroup($){
	my $hid = $_[0];
	my $requete = "SELECT  `id`,`group_name`
					FROM  `Host_Group` 
					WHERE  `id`=(SELECT `host_group` FROM `Host` WHERE `id`='".$hid."')";
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

sub getParType($){
	my $hid = $_[0];
	my $requete = "SELECT  `id`,`Name`
					FROM  `Host_Type` 
					WHERE  `id`=(SELECT `host_type` FROM `Host` WHERE `id`='".$hid."')";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my ($id,$gname) = $sth->fetchrow_array;
	my $html = '';
	if(defined $id){
	my ($up,$down,$unre) = getTypeSum($id);
		$html=$html.'
				<h2>Parent Type</h2>
				<a href="/type/show/'.$id.'">
					<div class="tile bg-color-blue">
						<div class="tile-content">
							<h4>'.$gname.'</h4>
							<h5>Host : '.($up+$down+$unre).'</h5><h5>Host UP : '.$up.'</h5><h5>Host down: '.$down.'</h5><h5>Host Unreachable: '.$unre.'</h5>
						</div>
					</div>
				</a>';
	}
	$sth->finish;
	$sdbh->disconnect;
	print $html;
		
	
}


sub getParHost($){
	my $bg ="";
	my $hid = $_[0];
	my $requete = "SELECT  `id`,`host_name`,`host_status`,`host_alias`,`host_address`
					FROM  `Host` 
					WHERE  `id`=(SELECT `parent_host` FROM `Host` WHERE `id`='".$hid."')";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my ($id,$hname,$sta,$halias,$hip) = $sth->fetchrow_array;
	my $html = '';
	if($sta eq "1"){
		$bg = "bg-color-green";
	}
	elsif($sta eq "0"){
		$bg = "bg-color-red";
	}
	elsif($sta eq "2"){
		$bg = "bg-color-grey";
	}
	if (!defined $hname){ $hname = ""};
	if (!defined $halias){ $halias = ""};
	if ( defined $id){
	$html=$html.'
		<h2>Parent Host</h2>
		<a href="/host/show/'.$id.'">
			<div class="tile '.$bg.'">
				<div class="tile-content">
					<h4>'.$hname.'</h4>
						<h5>Address: '.$hip.'</h5><h5>Alias: '.$halias.'</h5>
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
sub getHostChild($$){
	my $limit = "LIMIT 0,39";
	my $hid=$_[0];
	my $filter = $_[1];
	my $requete = "";
	if (defined $filter && $filter ne ""){
	$filter =~ s/'/\\'/g;
	$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL  AND  `parent_host`='".$hid."' AND `host_status`!=3 AND (`host_name` REGEXP '".$filter."' OR `host_type` REGEXP '".$filter."' OR `host_address` REGEXP '".$filter."' OR `host_alias` REGEXP '".$filter."' )
					ORDER BY `host_name` ".$limit;
	}else{
		$requete = "SELECT `Host`.`id`,`host_name`,`group_name`,`host_address`,`host_status`,`host_alias`,`Name` 
					FROM `Host` 
					LEFT OUTER JOIN `Host_Group` ON `Host`.`host_group`=`Host_Group`.`id` 
					LEFT OUTER JOIN `Host_Type` ON `Host`.`host_type`=`Host_Type`.`id` 
					WHERE `host_address` IS NOT NULL  AND  `parent_host`='".$hid."' AND `host_status`!='3'
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
	
	my ($hid,$info,$filter)=get_params($queryCGI);
	if(defined $hid && defined $info){ 
		if ($info eq "glo")
		{
		#For global info
		print $queryCGI->header('application/json');
			getHostInfo($hid);
		}
		#for sub group
		elsif ($info eq "sho")
		{
			print $queryCGI->header();
			getHostChild($hid,$filter);
		}
		elsif ($info eq "ph")
		{
			print $queryCGI->header();
			getParHost($hid);
		}
		elsif ($info eq "pg")
		{
			print $queryCGI->header();
			getParGroup($hid);
		}
		elsif ($info eq "pt")
		{
			print $queryCGI->header();
			getParType($hid);
		}
	
	}

}

main;
