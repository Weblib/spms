#!/usr/bin/perl
#
use strict;
use DBI;
use POSIX;
use AppConfig qw(:expand :argcount);
use CGI;

#Variable definitions
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

#function predeclaration
sub get_params;
sub haGlobalChart;
sub pieGlobalChart;
sub haGroupChart;
sub pieGroupChart;
sub haTypeChart;
sub pieTypeChart;
sub haHostChart;
sub pieHostChart;



sub get_params($){
my $gCGI = $_[0];
#GET mains args for statistic generation
#---------------------------------------------
#Period of stat generation

#hostname of device
my $info = $gCGI->param('info');
my $chart = $gCGI->param('chart');
my $id = $gCGI->param('id');
return ($info,$chart,$id);
}




sub pieGlobalChart{
	my $requete = "	SELECT COUNT( * ), `status` 
					FROM  `Data_Report` 
					WHERE  TO_DAYS(NOW()) - TO_DAYS(report_date) <= 30 AND `status` !='3'
					GROUP BY  `status` ";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $up=0;
	my $down=0;
	my $unre=0;
	while( my ($tc,$sts) = $sth->fetchrow_array){
		if($sts == 0){
		$down=$tc;
		}
		elsif($sts == 1){
		$up=$tc;
		}
		elsif($sts == 2){
		$unre=$tc;
		}
	}
	my $sum = ($up+$down+$unre)/100;
	if ($sum == 0){$sum=1};
	print "var data1 = [['Up',".$up/$sum."],['Down',".$down/$sum."],['Unreachable',".$unre/$sum."]];";
}

sub haGlobalChart{
	my $requete = "	SELECT  `report_date` , COUNT( * ) ,  `status` 
					FROM  `Data_Report` 
					WHERE  TO_DAYS(NOW()) - TO_DAYS(report_date) <= 30 AND `status` !='3'
					GROUP BY  `report_date` ,  `status` ";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	#stor data into variable to be use be javascript chart library
	my $varup= "var dup = [";
	my $vardown= "var ddown = [";
	my $varunre= "var dunre = [";
	my $vartot= "var dtot = [";
	#index to known how many index
	my $isfirst = 1;
	my $index=0;
	my $dates="";
	#checked if we pass all things
	my $isuppass =0;
	my $isdownpass =0;
	my $isunrepass =0;
	#data 
	my $up=0;
	my $down=0;
	my $unre=0;
	
	while( my ($date,$tc,$sts) = $sth->fetchrow_array){
		if( $index == 2 && ($date ne $dates ) ){
			
			#traitement de la donnée inexistante (nulle)
			if ($isuppass == 0){
				if ($isfirst == 1){
					$varup = $varup."['".$date."',".$up."]";
				}
				else{
					$varup = $varup.",['".$date."',".$up."]";
				}
			}
			elsif ($isunrepass == 0){
				if ($isfirst == 1){
					$varunre = $varunre."['".$date."',".$unre."]";
				}
				else{
					$varunre = $varunre.",['".$date."',".$unre."]";
				}
			}
			elsif ($isdownpass == 0){
				if ($isfirst == 1){
					$vardown = $vardown."['".$date."',".$down."]";
				}
				else{
					$vardown = $vardown.",['".$date."',".$down."]";
				}
			}
			
			# Ajout au total
			if ($isfirst == 1){
				$isfirst =0;
					$vartot = $vartot."['".$date."',".($down+$up+$unre)."]";
				}
				else{
					$vartot = $vartot.",['".$date."',".($down+$up+$unre)."]";
				}
			
			$isuppass = 0;
			$isdownpass = 0;
			$isunrepass = 0;
			$index = 0;
			$up = 0;
			$down = 0;
			$unre = 0;
			
			
		}
		
		
		#traitement de la donnée courante
		$dates = $date;
		
		if($sts == 0){
				if ($isfirst == 1){
				$down=$tc;
				$vardown = $vardown."['".$date."',".$down."]";
				}
				else{
				$down=$tc;
				$vardown = $vardown.",['".$date."',".$down."]";
				}
				$isdownpass = 1;
			}
		elsif($sts == 1){
				if ($isfirst == 1){
				$up=$tc;
				$varup = $varup."['".$date."',".$tc."]";
				}
				else{
				$up=$tc;
				$varup = $varup.",['".$date."',".$tc."]";
				}
				$isuppass = 1;
			}
		elsif($sts == 2){
				if ($isfirst == 1){
				$unre=$tc;
				$varunre = $varunre."['".$date."',".$unre."]";
				}
				else{
				$unre=$tc;
				$varunre = $varunre.",['".$date."',".$unre."]";
				}
				$isunrepass = 1;
			}
		#incrémentation de l'index
		
		$index++;
		
		#On a finit on fait la somme // End of treatment we do sum	
		if ($index == 3){
			if ($isfirst == 1){
					$vartot = $vartot."['".$date."',".($down+$up+$unre)."]";
				$isfirst =0;
				}
				else{
					$vartot = $vartot.",['".$date."',".($down+$up+$unre)."]";
				}
			$isuppass = 0;
			$isdownpass = 0;
			$isunrepass = 0;
			$index =0;
			$up=0;
			$down=0;
			$unre=0;
			}
		}
		
	
	#Cloture des fichiers
	$varup = $varup."];
	";
	$vardown = $vardown."];
	";
	$varunre = $varunre."];
	";
	$vartot = $vartot."];
	";
	
	#print
	print $varup;
	print $vardown;
	print $varunre;	
	print $vartot;	
		
}


sub pieGroupChart($){
	my $requete = "	SELECT COUNT(*),`status` 
					FROM  `Data_Report` 
					WHERE TO_DAYS( NOW( ) ) - TO_DAYS( report_date ) <=30 AND  `status` !=  '3' AND host_group =  '".$_[0]."' 
					GROUP BY `status`";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $up=0;
	my $down=0;
	my $unre=0;
	while( my ($tc,$sts) = $sth->fetchrow_array){
		if($sts == 0){
		$down=$tc;
		}
		elsif($sts == 1){
		$up=$tc;
		}
		elsif($sts == 2){
		$unre=$tc;
		}
	}
	my $sum = ($up+$down+$unre)/100;
	if ($sum == 0){$sum=1};
	print "var data1 = [['Up',".$up/$sum."],['Down',".$down/$sum."],['Unreachable',".$unre/$sum."]];";
}	
	
sub haGroupChart($){
	my $requete = "	SELECT  `report_date` , COUNT( * ) ,  `status` 
					FROM  `Data_Report` 
					WHERE  TO_DAYS(NOW()) - TO_DAYS(report_date) <= 30 AND `status` !='3' AND host_group =  '".$_[0]."' 
					GROUP BY  `report_date` ,  `status` ";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	#stor data into variable to be use be javascript chart library
	my $varup= "var dup = [";
	my $vardown= "var ddown = [";
	my $varunre= "var dunre = [";
	my $vartot= "var dtot = [";
	#index to known how many index
	my $isfirst = 1;
	my $index=0;
	my $dates="";
	#checked if we pass all things
	my $isuppass =0;
	my $isdownpass =0;
	my $isunrepass =0;
	#data 
	my $up=0;
	my $down=0;
	my $unre=0;
	
	while( my ($date,$tc,$sts) = $sth->fetchrow_array){
		if( ($index == 1 || $index == 2) && ($date ne $dates ) ){
			
			#traitement de la donnée inexistante (nulle)
			if ($isuppass == 0){
				if ($isfirst == 1){
					$varup = $varup."['".$date."',".$up."]";
				}
				else{
					$varup = $varup.",['".$date."',".$up."]";
				}
			}
			if ($isunrepass == 0){
				if ($isfirst == 1){
					$varunre = $varunre."['".$date."',".$unre."]";
				}
				else{
					$varunre = $varunre.",['".$date."',".$unre."]";
				}
			}
			if ($isdownpass == 0){
				if ($isfirst == 1){
					$vardown = $vardown."['".$date."',".$down."]";
				}
				else{
					$vardown = $vardown.",['".$date."',".$down."]";
				}
			}
			
			# Ajout au total
			if ($isfirst == 1){
				$isfirst =0;
					$vartot = $vartot."['".$date."',".($down+$up+$unre)."]";
				}
				else{
					$vartot = $vartot.",['".$date."',".($down+$up+$unre)."]";
				}
			
			$isuppass = 0;
			$isdownpass = 0;
			$isunrepass = 0;
			$index = 0;
			$up = 0;
			$down = 0;
			$unre = 0;
			
			
		}
		
		
		#traitement de la donnée courante
		$dates = $date;
		
		if($sts == 0){
				if ($isfirst == 1){
				$down=$tc;
				$vardown = $vardown."['".$date."',".$down."]";
				}
				else{
				$down=$tc;
				$vardown = $vardown.",['".$date."',".$down."]";
				}
				$isdownpass = 1;
			}
		elsif($sts == 1){
				if ($isfirst == 1){
				$up=$tc;
				$varup = $varup."['".$date."',".$tc."]";
				}
				else{
				$up=$tc;
				$varup = $varup.",['".$date."',".$tc."]";
				}
				$isuppass = 1;
			}
		elsif($sts == 2){
				if ($isfirst == 1){
				$unre=$tc;
				$varunre = $varunre."['".$date."',".$unre."]";
				}
				else{
				$unre=$tc;
				$varunre = $varunre.",['".$date."',".$unre."]";
				}
				$isunrepass = 1;
			}
		#incrémentation de l'index
		
		$index++;
		
		#On a finit on fait la somme // End of treatment we do sum	
		if ($index == 3){
			if ($isfirst == 1){
					$vartot = $vartot."['".$date."',".($down+$up+$unre)."]";
				$isfirst =0;
				}
				else{
					$vartot = $vartot.",['".$date."',".($down+$up+$unre)."]";
				}
			$isuppass = 0;
			$isdownpass = 0;
			$isunrepass = 0;
			$index =0;
			$up=0;
			$down=0;
			$unre=0;
			}
		}
		
	
	#Cloture des fichiers
	$varup = $varup."];
	";
	$vardown = $vardown."];
	";
	$varunre = $varunre."];
	";
	$vartot = $vartot."];
	";
	
	#print
	print $varup;
	print $vardown;
	print $varunre;	
	print $vartot;	
		
}


sub pieTypeChart($){
	my $requete = "	SELECT COUNT(*),`status` 
					FROM  `Data_Report` 
					WHERE TO_DAYS( NOW( ) ) - TO_DAYS( report_date ) <=30 AND  `status` !=  '3' AND host_type =  '".$_[0]."' 
					GROUP BY `status`";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $up=0;
	my $down=0;
	my $unre=0;
	while( my ($tc,$sts) = $sth->fetchrow_array){
		if($sts == 0){
		$down=$tc;
		}
		elsif($sts == 1){
		$up=$tc;
		}
		elsif($sts == 2){
		$unre=$tc;
		}
	}
	my $sum = ($up+$down+$unre)/100;
	if ($sum == 0){$sum=1};
	print "var data1 = [['Up',".$up/$sum."],['Down',".$down/$sum."],['Unreachable',".$unre/$sum."]];";
}	
	
sub haTypeChart($){
	my $requete = "	SELECT  `report_date` , COUNT( * ) ,  `status` 
					FROM  `Data_Report` 
					WHERE  TO_DAYS(NOW()) - TO_DAYS(report_date) <= 30 AND `status` !='3' AND host_type =  '".$_[0]."' 
					GROUP BY  `report_date` ,  `status` ";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	#stor data into variable to be use be javascript chart library
	my $varup= "var dup = [";
	my $vardown= "var ddown = [";
	my $varunre= "var dunre = [";
	my $vartot= "var dtot = [";
	#index to known how many index
	my $isfirst = 1;
	my $index=0;
	my $dates="";
	#checked if we pass all things
	my $isuppass =0;
	my $isdownpass =0;
	my $isunrepass =0;
	#data 
	my $up=0;
	my $down=0;
	my $unre=0;
	
	while( my ($date,$tc,$sts) = $sth->fetchrow_array){
		if( ($index == 2 || $index == 1 ) && ($date ne $dates ) ){
			
			#traitement de la donnée inexistante (nulle)
			if ($isuppass == 0){
				if ($isfirst == 1){
					$varup = $varup."['".$date."',".$up."]";
				}
				else{
					$varup = $varup.",['".$date."',".$up."]";
				}
			}
			if ($isunrepass == 0){
				if ($isfirst == 1){
					$varunre = $varunre."['".$date."',".$unre."]";
				}
				else{
					$varunre = $varunre.",['".$date."',".$unre."]";
				}
			}
			if ($isdownpass == 0){
				if ($isfirst == 1){
					$vardown = $vardown."['".$date."',".$down."]";
				}
				else{
					$vardown = $vardown.",['".$date."',".$down."]";
				}
			}
			
			# Ajout au total
			if ($isfirst == 1){
				$isfirst =0;
					$vartot = $vartot."['".$date."',".($down+$up+$unre)."]";
				}
				else{
					$vartot = $vartot.",['".$date."',".($down+$up+$unre)."]";
				}
			
			$isuppass = 0;
			$isdownpass = 0;
			$isunrepass = 0;
			$index = 0;
			$up = 0;
			$down = 0;
			$unre = 0;
			
			
		}
		
		
		#traitement de la donnée courante
		$dates = $date;
		
		if($sts == 0){
				if ($isfirst == 1){
				$down=$tc;
				$vardown = $vardown."['".$date."',".$down."]";
				}
				else{
				$down=$tc;
				$vardown = $vardown.",['".$date."',".$down."]";
				}
				$isdownpass = 1;
			}
		elsif($sts == 1){
				if ($isfirst == 1){
				$up=$tc;
				$varup = $varup."['".$date."',".$tc."]";
				}
				else{
				$up=$tc;
				$varup = $varup.",['".$date."',".$tc."]";
				}
				$isuppass = 1;
			}
		elsif($sts == 2){
				if ($isfirst == 1){
				$unre=$tc;
				$varunre = $varunre."['".$date."',".$unre."]";
				}
				else{
				$unre=$tc;
				$varunre = $varunre.",['".$date."',".$unre."]";
				}
				$isunrepass = 1;
			}
		#incrémentation de l'index
		
		$index++;
		
		#On a finit on fait la somme // End of treatment we do sum	
		if ($index == 3){
			if ($isfirst == 1){
					$vartot = $vartot."['".$date."',".($down+$up+$unre)."]";
				$isfirst =0;
				}
				else{
					$vartot = $vartot.",['".$date."',".($down+$up+$unre)."]";
				}
			$isuppass = 0;
			$isdownpass = 0;
			$isunrepass = 0;
			$index =0;
			$up=0;
			$down=0;
			$unre=0;
			}
		}
		
	
	#Cloture des fichiers
	$varup = $varup."];
	";
	$vardown = $vardown."];
	";
	$varunre = $varunre."];
	";
	$vartot = $vartot."];
	";
	
	#print
	print $varup;
	print $vardown;
	print $varunre;	
	print $vartot;	
		
}

sub pieHostChart($){
	my $requete = "	SELECT COUNT(*),`status`
					FROM  `Data_Report`
					WHERE TO_DAYS( NOW( ) ) - TO_DAYS( report_date ) <=30 AND  `status` !=  '3' AND host_id =  '".$_[0]."' 
					GROUP BY `status`";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	my $up=0;
	my $down=0;
	my $unre=0;
	while( my ($tc,$sts) = $sth->fetchrow_array ){
		if($sts == 0){
		$down=$tc;
		}
		elsif($sts == 1){
		$up=$tc;
		}
		elsif($sts == 2){
		$unre=$tc;
		}
	}
	my $sum = ($up+$down+$unre)/100;
	if ($sum == 0){$sum=1};
	print "var data1 = [['Up',".$up/$sum."],['Down',".$down/$sum."],['Unreachable',".$unre/$sum."]];";
}	
	
sub haHostChart($){
	my $requete = "	SELECT  `report_date` , COUNT( * ) ,  `status` 
					FROM  `Data_Report` 
					WHERE  TO_DAYS(NOW()) - TO_DAYS(report_date) <= 30 AND `status` !='3' AND host_id =  '".$_[0]."' 
					GROUP BY  `report_date` ,  `status` ";
	my $sdbh = DBI->connect($sdsn, $dbUser, $dbPass) or die "Echec connexion";
	my $sth = $sdbh->prepare($requete);
    $sth->execute();
	#stor data into variable to be use be javascript chart library
	my $varup= "var dup = [";
	my $vardown= "var ddown = [";
	my $varunre= "var dunre = [";
	#index to known how many index
	my $isfirst = 1;
	
	while( my ($date,$tc,$sts) = $sth->fetchrow_array){

		if($sts == 0){
				if ($isfirst == 1){
					$vardown = $vardown."['".$date."',".($tc*100)."]";
					$varup = $varup."['".$date."',0]";
					$varunre = $varunre."['".$date."',0]";
					$isfirst =0;
				}
				else{
					$vardown = $vardown.",['".$date."',".($tc*100)."]";
					$varup = $varup.",['".$date."',0]";
					$varunre = $varunre.",['".$date."',0]";
				}

			}
		elsif($sts == 1){
				if ($isfirst == 1){
					$vardown = $vardown."['".$date."',0]";
					$varup = $varup."['".$date."',".($tc*100)."]";
					$varunre = $varunre."['".$date."',0]";
					$isfirst =0;
				}
				else{
					$vardown = $vardown.",['".$date."',0]";
					$varup = $varup.",['".$date."',".($tc*100)."]";
					$varunre = $varunre.",['".$date."',0]";
				}

			}
		elsif($sts == 2){
				if ($isfirst == 1){
					$vardown = $vardown."['".$date."',0]";
					$varup = $varup."['".$date."',0]";
					$varunre = $varunre."['".$date."',".($tc*100)."]";
					$isfirst =0;
				}
				else{
					$vardown = $vardown.",['".$date."',0]";
					$varup = $varup.",['".$date."',0]";
					$varunre = $varunre.",['".$date."',".($tc*100)."]";
				}

			}
		
		}
		
	
	#Cloture des fichiers
	$varup = $varup."];
	";
	$vardown = $vardown."];
	";
	$varunre = $varunre."];
	";

	
	#print
	print $varup;
	print $vardown;
	print $varunre;	
		
}


sub main{

	#data collected
	my $queryCGI = CGI->new;
	print $queryCGI->header('application/javascript');
	my ($info,$chart,$id)=get_params($queryCGI);
	if (defined $info && defined $chart){
		if ($info eq "global"){
			if($chart eq "ha"){
				haGlobalChart;
			}
			elsif($chart eq "upt"){
				pieGlobalChart;
			}
		}
		elsif($info eq "group"){
			if($chart eq "ha"){
				haGroupChart($id);
			}
			elsif($chart eq "upt"){
				pieGroupChart($id);
			}
		}
		elsif($info eq "type"){
			if($chart eq "ha"){
				haTypeChart($id);
			}
			elsif($chart eq "upt"){
				pieTypeChart($id);
			}
		}
		elsif($info eq "host"){
			if($chart eq "ha"){
				haHostChart($id);
			}
			elsif($chart eq "upt"){
				pieHostChart($id);
			}
			
		}
		
	}
	
	
	
	
	


}

main;
