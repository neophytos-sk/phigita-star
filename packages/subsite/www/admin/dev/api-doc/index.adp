<master>
<property name="title">API Browser</property>

<if @tclproc@ not nil>
Viewing Procedure: <b>@tclproc@</b> <i>@procargs@</i>
      <pre>
@pretty_procbody;noquote@
	
      </pre>
</if>
<else>

   <blockquote>

	<font size=-2>
		<list name=allprocs>
			<a href=?tclproc=@allprocs:item@>@allprocs:item@</a>
		</list>
	<hr width="50%">
		<list name=allcmds>
			<a href=?tclproc=@allcmds:item@>@allcmds:item@</a>
		</list>
	</font>
    </blockquote>
</else>
