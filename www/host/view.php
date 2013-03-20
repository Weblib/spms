<?php

function hostView($host){
	include 'head.php';
	include 'menu.php';
?>
	<script type="text/javascript" src="/js/host.js"></script>
	<div id="entity-id" style="display:none"><?echo $host; ?></div>
	<div class="page">
	<h1 id="entity-name">&nbsp;Host :<?echo $host; ?></h1>
	<div class="left-h">
		<table>
				<tr>
					<td class="column" >
						<h2>Host Overview</h2>
						<div id="overview" class="tile double ">
							<div class="tile-content">
								<h4 id="hname" class="fg-color-white"></h4>
								<h5 id="halias" class="fg-color-white"></h5>
								<h5 id="hadd" class="fg-color-white"></h5>
								<h5 id="hstat" class="fg-color-white"></h5>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<td class="column" id="parent-group">
					</td>
				</tr>
				<tr>
					<td  class="column" id="parent-type">
					</td>
				</tr>
				<tr>
					<td  class="column" id="parent-host">
					</td>
				</tr>
		</table>
	</div>
	<div class="left-h">
		<table>
			<tr>
				<td>
				<h2>UP Time</h2>
					<div id="overlay1">
						<center><img src="/images/preloader-w8-cycle-black.gif" alt="Loading" /><br>
					Loading...</center>
						</div>
					<div id="up-time">
					</div>
				</td>
			</tr>
			<tr>
				<td>
				<h2>Host Reachability Chart</h2>
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
	<div class="left-gp2">
			<h2>Child Host <a href="javascript:affSearch()" >Search</a>/<a href="javascript:resSearch()" >Reset Search</a></h2>
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