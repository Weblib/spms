<?php
function typeView($host){
	include 'head.php';
	include 'menu.php';
?>
	<script type="text/javascript" src="/js/type.js"></script>
	<div id="entity-id" style="display:none"><?echo $host; ?></div>
	<div class="page">
	<h1 id="entity-name">&nbsp;Type </h1>
		<div class="left">
			<table>
			<tr><td class="column">
			<h2>Type Overview</h2>
			<div id="overview">
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
			</div>
			</td>
			</tr>
			<tr><td>
			<h2>Current Month Global Uptime</h2>
			<div id="overlay1">
						<center><img src="/images/preloader-w8-cycle-black.gif" alt="Loading" /><br>
					Loading...</center>
						</div>
				<div id="piec">
				</div>
			</tr></td>
			<tr><td>
			<h2>Number of alive Hosts Evolution</h2>
			
				<div id="overlay2">
						<center><img src="/images/preloader-w8-cycle-black.gif" alt="Loading" /><br>
					Loading...</center>
						</div>
				</div>
			<div id="hac">
			</div>
			</tr></td>
			</table>
		</div>
		<div class="left-gp2">
			<h2>Hosts <a href="javascript:affSearch()" >Search</a>/<a href="javascript:resSearch()" >Reset Search</a></h2>
			<div id="sub-host">
			</div>
		</div>
		<div id="search" class="charms" style="display: none;">
		<div class="content">
		<h2>Search</h2>
		<a href="javascript:hideSearch()"><h3>Close</h3></a>
		<form id="form-search">
		<div class="input-control text span3 as-block">
            <input id="text-search" type="text" class="with-helper">
            <button class="helper" tabindex="-1" type="button" onClick="javascript:resSearch()"></button>
        </div>
		</form>
		</div>
	</div>
	</div>
	</body></html>
<?

}



?>