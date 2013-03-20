 <div class="nav-bar">
        <div class="nav-bar-inner padding10">
 
            <span class="element">Simple Ping Monitoring System</span>
 
            <span class="divider"></span>
 
            <ul class="menu">
				<li><a href="/report/global/">Global Report</a></li>
				<li><a href="/report/hosts/">Hosts Report</a></li>
                <li><a href="/report/groups/">Groups Report</a></li>
                <li><a href="/report/types">Types Report</a></li>
				<?if ($_SESSION["isLog"]){ ?>
				<li data-role="dropdown"><a>Add</a>
					<ul class="dropdown-menu">
                        <li><a href="/host/add/">Host</a></li>
                        <li><a href="#">Host Group</a></li>
						<li><a href="#">Type</a></li>
                    </ul>
				</li>
				<li data-role="dropdown"><a>Delete</a>
					<ul class="dropdown-menu">
                        <li><a href="/host/add/">Host</a></li>
                        <li><a href="#">Host Group</a></li>
						<li><a href="#">Type</a></li>
                    </ul>
				</li>
				<li data-role="dropdown"><a>Edit</a>
					<ul class="dropdown-menu">
                        <li><a href="/host/edit/">Host</a></li>
                        <li><a href="#">Host Group</a></li>
						<li><a href="#">Type</a></li>
                    </ul>
				</li>
				<? }?>
				<li><a href="/search/">Search</a></li>
                <li class="divider"></li>
            </ul>
        </div>
    </div>
	<!-- Menu End -->