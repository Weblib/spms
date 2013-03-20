
var hostid = "";
var filter = "";

 $(document).ready(function() {
		hostid = $("#entity-id").html();
		$.get("/API/getonehost.pl?info=glo&id=" + hostid,function(data){
			$("#entity-name").html("&nbsp;Host : "+ data.name);
			$("#hname").html("&nbsp;"+ data.name);
			$("#halias").html("&nbsp;Alias : "+ data.halias);
			$("#hadd").html("&nbsp;Address : "+ data.hadd);
			if(data.stat == "Up"){
			$("#overview").addClass("bg-color-green");
			$("#hstat").html("&nbsp;Status : "+ data.stat);
			}
			else if(data.stat == "Down"){
			$("#overview").addClass("bg-color-red");
			$("#hstat").html("&nbsp;Status : "+ data.stat);
			}
			else if(data.stat == "Unreachable"){
			$("#overview").addClass("bg-color-grey");
			$("#hstat").html("&nbsp;Status : "+ data.stat);
			}
		},"json");
		$.get("/API/getonehost.pl?info=pg&id=" + hostid,function(data){
			$("#parent-group").html( data);
		});
		$.get("/API/getonehost.pl?info=pt&id=" + hostid,function(data){
			$("#parent-type").html( data);
		});
		$.get("/API/getonehost.pl?info=ph&id=" + hostid,function(data){
			$("#parent-host").html( data);
		});
		$.get("/API/getonehost.pl?info=sho&id=" + hostid + filter,function(data){
			$("#sub-host").html( data);
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
		
		$.getScript("/API/chart.pl?info=host&chart=upt&id=" + hostid,function(){
		$('#overlay1').fadeOut();
			var piec = jQuery.jqplot ('up-time', [data1], 
					{ 
					seriesDefaults: {
					// Make this a pie chart.
					renderer: jQuery.jqplot.PieRenderer, 
					rendererOptions: {
					// Put data labels on the pie slices.
					// By default, labels show the percentage of the slice.
							showDataLabels: true,
							diameter :180,
							sliceMargin: 4
						}
					}, 
					legend: { show:true, placement: 'outsideGrid' ,location:'s' ,rendererOptions: {
					numberRows: 1
						}, 
					},
					seriesColors: ["#00a300","#b91d47","#525252"]
					}
			);
		});
		
		$.getScript("/API/chart.pl?info=host&chart=ha&id=" + hostid,function(){
		$('#overlay2').fadeOut();
			var piec = jQuery.jqplot ('hac', [dup,ddown,dunre], 
					{ 
					series:[{showMarker:false, fill: true},{showMarker:false, fill: true},{showMarker:false, fill: true}],
					axes:{
						xaxis:{
								renderer:$.jqplot.DateAxisRenderer, 
								tickOptions:{formatString:'%#d %b %y,%Hh'},
								tickInterval:'1 week'
								},
						yaxis:{
							min:0,
							}
						},
					cursor:{ 
							show: true,
							zoom:true, 
							showTooltip:false
					},
					seriesColors: ["#00a300","#b91d47","#525252"]
					}
			);
		});
		
		
		var refreshId = setInterval(function() {
		$.get("/API/getonehost.pl?info=glo&id=" + hostid,function(data){
			$("#entity-name").html("&nbsp;Host : "+ data.name);
			$("#hname").html("&nbsp;"+ data.name);
			$("#halias").html("&nbsp;Alias : "+ data.halias);
			$("#hadd").html("&nbsp;Address : "+ data.hadd);
			$("#hstat").html("&nbsp;Status : "+ data.stat);
		},"json");
		$.get("/API/getonehost.pl?info=pg&id=" + hostid,function(data){
			$("#parent-group").html( data);
		});
		$.get("/API/getonehost.pl?info=pt&id=" + hostid,function(data){
			$("#parent-type").html( data);
		});
		$.get("/API/getonehost.pl?info=ph&id=" + hostid,function(data){
			$("#parent-host").html( data);
		});
		$.get("/API/getonehost.pl?info=sho&id=" + hostid + filter,function(data){
			$("#sub-host").html( data);
		});
		}, 1000);
		
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