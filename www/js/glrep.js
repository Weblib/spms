 $(document).ready(function() {
 	 $.get("/API/up.pl",function(data){
		$("#global-up").html(data.up);
		$("#global-down").html(data.down);
		$("#global-unre").html(data.unre);
	  },"json");
	  $.get("/API/sumgp.pl",function(data){
		$(".group-0").html(data.group0.name);
		$("#group-0-up").html(data.group0.up);
		$("#group-0-down").html(data.group0.down);
		$("#group-0-unre").html(data.group0.unre);
		$("#a-group-0").attr("href","/group/show/"+data.group0.id);
		$(".group-1").html(data.group1.name);
		$("#group-1-up").html(data.group1.up);
		$("#group-1-down").html(data.group1.down);
		$("#group-1-unre").html(data.group1.unre);
		$("#a-group-1").attr("href","/group/show/"+data.group1.id);
		$(".group-2").html(data.group2.name);
		$("#group-2-up").html(data.group2.up);
		$("#group-2-down").html(data.group2.down);
		$("#group-2-unre").html(data.group2.unre);
		$("#a-group-2").attr("href","/group/show/"+data.group2.id);
		$(".group-3").html(data.group3.name);
		$("#group-3-up").html(data.group3.up);
		$("#group-3-down").html(data.group3.down);
		$("#group-3-unre").html(data.group3.unre);
		$("#a-group-3").attr("href","/group/show/"+data.group3.id);
		$(".group-4").html(data.group4.name);
		$("#group-4-up").html(data.group4.up);
		$("#group-4-down").html(data.group4.down);
		$("#group-4-unre").html(data.group4.unre);
		$("#a-group-4").attr("href","/group/show/"+data.group4.id);
	  },"json");
	  $.get("/API/sumtp.pl",function(data){
		$(".type-0").html(data.type0.name);
		$("#type-0-up").html(data.type0.up);
		$("#type-0-down").html(data.type0.down);
		$("#type-0-unre").html(data.type0.unre);
		$("#a-type-0").attr("href","/type/show/"+data.type0.id);
		$(".type-1").html(data.type1.name);
		$("#type-1-up").html(data.type1.up);
		$("#type-1-down").html(data.type1.down);
		$("#type-1-unre").html(data.type1.unre);
		$("#a-type-1").attr("href","/type/show/"+data.type1.id);
		$(".type-2").html(data.type2.name);
		$("#type-2-up").html(data.type2.up);
		$("#type-2-down").html(data.type2.down);
		$("#type-2-unre").html(data.type2.unre);
		$("#a-type-2").attr("href","/type/show/"+data.type2.id);
		$(".type-3").html(data.type3.name);
		$("#type-3-up").html(data.type3.up);
		$("#type-3-down").html(data.type3.down);
		$("#type-3-unre").html(data.type3.unre);
		$("#a-type-3").attr("href","/type/show/"+data.type3.id);
		$(".type-4").html(data.type4.name);
		$("#type-4-up").html(data.type4.up);
		$("#type-4-down").html(data.type4.down);
		$("#type-4-unre").html(data.type4.unre);
		$("#a-type-4").attr("href","/type/show/"+data.type4.id);
	  },"json");
	  
	  $.getScript("/API/chart.pl?info=global&chart=upt",function(){
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
		$.getScript("/API/chart.pl?info=global&chart=ha",function(){
		$('#overlay2').fadeOut();
			var piec = jQuery.jqplot ('hac', [dup,ddown,dunre,dtot], 
					{ 
					series:[{showMarker:false},{showMarker:false},{showMarker:false},{showMarker:false}],
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
	$.get("/API/up.pl",function(data){
		$("#global-up").html(data.up);
		$("#global-down").html(data.down);
		$("#global-unre").html(data.unre);
	  },"json");
	$.get("/API/sumgp.pl",function(data){
		$(".group-0").html(data.group0.name);
		$("#group-0-up").html(data.group0.up);
		$("#group-0-down").html(data.group0.down);
		$("#group-0-unre").html(data.group0.unre);
		$("#a-group-0").attr("href","/group/show/"+data.group0.id);
		$(".group-1").html(data.group1.name);
		$("#group-1-up").html(data.group1.up);
		$("#group-1-down").html(data.group1.down);
		$("#group-1-unre").html(data.group1.unre);
		$("#a-group-1").attr("href","/group/show/"+data.group1.id);
		$(".group-2").html(data.group2.name);
		$("#group-2-up").html(data.group2.up);
		$("#group-2-down").html(data.group2.down);
		$("#group-2-unre").html(data.group2.unre);
		$("#a-group-2").attr("href","/group/show/"+data.group2.id);
		$(".group-3").html(data.group3.name);
		$("#group-3-up").html(data.group3.up);
		$("#group-3-down").html(data.group3.down);
		$("#group-3-unre").html(data.group3.unre);
		$("#a-group-3").attr("href","/group/show/"+data.group3.id);
		$(".group-4").html(data.group4.name);
		$("#group-4-up").html(data.group4.up);
		$("#group-4-down").html(data.group4.down);
		$("#group-4-unre").html(data.group4.unre);
		$("#a-group-4").attr("href","/group/show/"+data.group4.id);
	  },"json");
	  $.get("/API/sumtp.pl",function(data){
		$(".type-0").html(data.type0.name);
		$("#type-0-up").html(data.type0.up);
		$("#type-0-down").html(data.type0.down);
		$("#type-0-unre").html(data.type0.unre);
		$("#a-type-0").attr("href","/type/show/"+data.type0.id);
		$(".type-1").html(data.type1.name);
		$("#type-1-up").html(data.type1.up);
		$("#type-1-down").html(data.type1.down);
		$("#type-1-unre").html(data.type1.unre);
		$("#a-type-1").attr("href","/type/show/"+data.type1.id);
		$(".type-2").html(data.type2.name);
		$("#type-2-up").html(data.type2.up);
		$("#type-2-down").html(data.type2.down);
		$("#type-2-unre").html(data.type2.unre);
		$("#a-type-2").attr("href","/type/show/"+data.type2.id);
		$(".type-3").html(data.type3.name);
		$("#type-3-up").html(data.type3.up);
		$("#type-3-down").html(data.type3.down);
		$("#type-3-unre").html(data.type3.unre);
		$("#a-type-3").attr("href","/type/show/"+data.type3.id);
		$(".type-4").html(data.type4.name);
		$("#type-4-up").html(data.type4.up);
		$("#type-4-down").html(data.type4.down);
		$("#type-4-unre").html(data.type4.unre);
		$("#a-type-4").attr("href","/type/show/"+data.type4.id);
	  },"json");
   }, 5000);
   $.ajaxSetup({ cache: false });
});