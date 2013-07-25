<table cellpadding=1 cellspacing=0 border=0 width="90%">
        <tr>
                <td><small><b>Quick Add Task</b></small></td>
        </tr>
        <tr>
                <td bgcolor=#B6C7E5>
                <table cellpadding=4 cellspacing=1 border=0 width="100%">

                <tr>
	    <multiple name=elements>

                <td valign=top bgcolor=#EEF3FB>

		  <if @elements.section@ not nil>
		  <small>@elements.section@</small><br>
		  </if>

		  <group column="section">


        	       <noparse><formwidget id=@elements.id@></noparse>


		  </group>
		</td>
	    </multiple>
		</tr>
		</table>
		</td>

	</tr>
</table>
		
