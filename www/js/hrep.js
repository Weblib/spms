var morehost = "";
var filter ="";

 $(document).ready(function() {
 	 $.get("/API/up.pl",function(data){
		$("#global-up").html('Hosts Up : ' + data.up + '<a href="javascript:moreHost()">&nbsp&nbsp;See all</a>/<a href="javascript:lessHost()">See less</a>/<a href="javascript:affSearch()">Search</a>/<a href="javascript:resSearch()">Reset Search</a>');
		$("#global-down").html('Hosts Down : ' + data.down + '<a href="javascript:moreHost()">&nbsp&nbsp;See all</a>/<a href="javascript:lessHost()">See less</a>/<a href="javascript:affSearch()">Search</a>/<a href="javascript:resSearch()">Reset Search</a>');
		$("#global-unre").html('Hosts Unreachable : ' + data.unre + '<a href="javascript:affSearch()">&nbsp&nbsp;Search</a>/<a href="javascript:resSearch()">Reset Search</a>');
	  },"json");
	  $.get("/API/gethost.pl?st=up" + morehost + filter,function(data){
		$("#hosts-up").html(data);
		});
	  $.get("/API/gethost.pl?st=do" + morehost + filter,function(data){
		$("#hosts-down").html(data);
		});
	  $.get("/API/gethost.pl?st=un" + morehost + filter,function(data){
		$("#hosts-unre").html(data);
		});
		$('#text-search').keyup(function(e) {
			filter = "&fi=" +$('#text-search').val();
			if(e.keyCode == 13) {
				filter = "&fi=" +$('#text-search').val();
			}
		});
		$('#form-search').submit(function() {
			filter = "&fi=" +$('#text-search').val();		
		});

   var refreshId = setInterval(function() {
	$.get("/API/up.pl",function(data){
		$("#global-up").html('Hosts Up : ' + data.up + '<a href="javascript:moreHost()">&nbsp&nbsp;See all</a>/<a href="javascript:lessHost()">See less</a>/<a href="javascript:affSearch()">Search</a>/<a href="javascript:resSearch()">Reset Search</a>');
		$("#global-down").html('Hosts Down : ' + data.down + '<a href="javascript:moreHost()">&nbsp&nbsp;See all</a>/<a href="javascript:lessHost()">See less</a>/<a href="javascript:affSearch()">Search</a>/<a href="javascript:resSearch()">Reset Search</a>');
		$("#global-unre").html('Hosts Unreachable : ' + data.unre + '<a href="javascript:affSearch()">&nbsp&nbsp;Search</a>/<a href="javascript:resSearch()">Reset Search</a>');
	  },"json");
	$.get("/API/gethost.pl?st=up" + morehost + filter,function(data){
		$("#hosts-up").html(data);
		});
	$.get("/API/gethost.pl?st=do" + morehost + filter,function(data){
		$("#hosts-down").html(data);
		});
	$.get("/API/gethost.pl?st=un" + morehost + filter,function(data){
		$("#hosts-unre").html(data);
		});
   }, 1000);
   $.ajaxSetup({ cache: false });
});

function affSearch(){
	$("#search").css("display","");
}

function hideSearch(){
	$("#search").css("display","none");
}

function moreHost(){
	morehost = "&mo=more";
}

function lessHost(){
	morehost = "";
}

function resSearch(){
	$('#text-search').val('');
	filter = '';
	hideSearch();
}