<?php
include 'head.php';
include 'menu.php';

function drawTile($type,$num){
		
	echo '	<a id="a-'.$type.'-'.$num.'" href=""><div class="tile bg-color-green">
                                    <div class="tile-content" style="position: absolute; left: 0px; top: 0px;">
                                        <h2 class="'.$type.'-'.$num.'">'.$type.'-'.$num.'</h2>
										<h3>Hosts UP</h3>
                                    </div>
                                    <div class="brand">
                                        <div id="'.$type.'-'.$num.'-up" class="badge">12</div>
                                    </div>
        </div>
		<div class="tile bg-color-red">
                                    <div class="tile-content" style="position: absolute; left: 0px; top: 0px;">
                                        <h2 class="'.$type.'-'.$num.'">'.$type.'-'.$num.'</h2>
										<h3>Hosts Down</h3>
                                    </div>
                                    <div class="brand">
                                        <div id="'.$type.'-'.$num.'-down" class="badge">12</div>
                                    </div>
        </div>
		<div class="tile bg-color-grey">
                                    <div class="tile-content" style="position: absolute; left: 0px; top: 0px;">
                                        <h2 class="'.$type.'-'.$num.'">'.$type.'-'.$num.'</h2>
										<h3>Hosts Unreachable</h3>
                                    </div>
                                    <div class="brand">
                                        <div id="'.$type.'-'.$num.'-unre" class="badge">12</div>
                                    </div>
        </div></a>';

}

function drawGpTile(){
	$i=0;
	while($i<5){
		drawTile("group",$i);
	$i++;
	}
}

function drawTpTile(){
	$i=0;
	while($i<5){
		drawTile("type",$i);
	$i++;
	}
}

?>
<script type="text/javascript" src="/js/glrep.js"></script>
<div class="page">
<h1>&nbsp;Global Report</h1>
	<div class="left">
		<table>
		<tr><td class="column">
		<h2>Global Overview</h2>
		<div class="tile bg-color-green">
                                    <div class="tile-content" style="position: absolute; left: 0px; top: 0px;">
                                        <h2>Now</h2>
										<h3>Hosts UP</h3>
                                    </div>
                                    <div class="brand">
                                        <div id="global-up" class="badge">12</div>
                                    </div>
        </div>
		<div class="tile bg-color-red">
                                    <div class="tile-content" style="position: absolute; left: 0px; top: 0px;">
                                        <h2>Now</h2>
										<h3>Hosts Down</h3>
                                    </div>
                                    <div class="brand">
                                        <div id="global-down" class="badge">12</div>
                                    </div>
        </div>
		<div class="tile bg-color-grey">
                                    <div class="tile-content" style="position: absolute; left: 0px; top: 0px;">
                                        <h2>Now</h2>
										<h3>Hosts Unreachable</h3>
                                    </div>
                                    <div class="brand">
                                        <div id="global-unre" class="badge">12</div>
                                    </div>
        </div>
	
	</td>
	</tr>
	<tr>
		<td class="column">
			<h2>Current Month Global Uptime</h2>
				<div id="overlay1">
						<center><img src="/images/preloader-w8-cycle-black.gif" alt="Loading" /><br>
					Loading...</center>
				</div>
			<div id="piec">
			</div>
		</td>
	</tr>
	<tr>
		<td class="column">
		<h2>Number of alive Hosts Evolution</h2>
			<div id="overlay2">
						<center><img src="/images/preloader-w8-cycle-black.gif" alt="Loading" /><br>
					Loading...</center>
						</div>
			<div id="hac">
			</div>
		</td>
	</tr>
	</table>
	</div>
	<div class="left">
		<a href="/report/groups/"><h2>Groups Overview</h2></a>
		<? drawGpTile();?>
		<a href="/report/groups/"><h2>More Groups</h2></a>
	</div>
	<div class="left">
		<a href="/report/types/"><h2>Types Overview</h2></a>
		<? drawTpTile();?>
		<a href="/report/types/"><h2>More Types</h2></a>
	</div>
	<div class="clear"></div>
</div>
</body></html>