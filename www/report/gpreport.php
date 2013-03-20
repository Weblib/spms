<?php
include 'head.php';
include 'menu.php';
?>
<script type="text/javascript" src="/js/gprep.js"></script>
<div class="page">
<h1>&nbsp;Groups Report</h1>
	<div class="left-gp">
		<h2></a>Group List
			<a href="javascript:moreHost()">&nbsp;See all</a>/<a href="javascript:lessHost()">See less</a>/<a href="javascript:affSearch()" >Search</a>/<a href="javascript:resSearch()" >Reset Search</a>
		</h2>
		<div id="group-list">
		</div>
			
	</div>
	<div class="clear"></div>
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
