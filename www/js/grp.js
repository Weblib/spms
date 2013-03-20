
var groupid = "";
var filter = "";

 $(document).ready(function() {
		groupid = $("#entity-id").html();
		$.get("/API/getonegroup.pl?info=glo&id=" + groupid,function(data){
			$("#entity-name").html("&nbsp;Group : "+ data.name);
			$("#global-up").html(data.up);
			$("#global-down").html( data.down);
			$("#global-unre").html(data.unre);
			},"json");
		$.get("/API/getonegroup.pl?info=sgp&id=" + groupid,function(data){
			$("#sub-group").html( data);
		});
		$.get("/API/getonegroup.pl?info=par&id=" + groupid,function(data){
			$("#parent-group").html( data);
		});
		$.get("/API/getonegroup.pl?info=sho&id=" + groupid + filter,function(data){
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
		$.getScript("/API/chart.pl?info=group&chart=upt&id=" + groupid,function(){
		$('#overlay1').fadeOut();
			var piec = jQuery.jqplot ('piec', [data1], 
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
			$.getScript("/API/chart.pl?info=group&chart=ha&id=" +  groupid,function(){
			$('#overlay2').fadeOut();
			var piec = jQuery.jqplot ('hac', [dup,ddown,dunre,dtot], 
					{ 
					series:[{showMarker:false,fill:true},{showMarker:false,fill:true},{showMarker:false,fill:true},{showMarker:false}],
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
					seriesColors: ["#00a300","#b91d47","#525252","#2d89ef"]
					}
			);
		});
	
		
		var refreshId = setInterval(function() {
		$.get("/API/getonegroup.pl?info=glo&id=" + groupid,function(data){
			$("#entity-name").html("&nbsp;Group : "+ data.name);
			$("#global-up").html(data.up);
			$("#global-down").html( data.down);
			$("#global-unre").html(data.unre);
			},"json");
		$.get("/API/getonegroup.pl?info=sgp&id=" + groupid,function(data){
			$("#sub-group").html( data);
		});
		$.get("/API/getonegroup.pl?info=par&id=" + groupid,function(data){
			$("#parent-group").html( data);
		});
		$.get("/API/getonegroup.pl?info=sho&id=" + groupid + filter,function(data){
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