<?php
include 'head.php';
include 'menu.php';
?>
<script type="text/javascript" src="/js/hrep.js"></script>
<div class="page">
<h1>&nbsp;Hosts Report</h1>
	<div class="page left-4">
		<h2 id="global-up">Hosts UP</h2>
		<div id="hosts-up">
		</div>
	</div>
	
	<div class="page left-4">
		<h2 id="global-down">Hosts Down</h2>
		<div id="hosts-down">
		</div>
	</div>
	
	<div class="page left-2">
		<h2 id="global-unre">Hosts Unreachable </h2>
		<div id="hosts-unre">
		</div>
	</div>
	
	<div class="clear"></div>
	
	<div id="search" class="charms" style="display: none;">
		<h2>Search</h2>
			</a><a href="javascript:hideSearch()"><h3>Close</h3></a>
			<form id="form-search">
			<div class="input-control text span3 as-block">
				<input id="text-search" type="text" class="with-helper">
			</div>
			</form>
	</div>
	
</div>
</body></html>