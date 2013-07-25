doc_return 200 text/plain {

<div>Starting fotonotes.php ...</div>

<div>Creating FNImage...</div>

<div>url_parts</div>

<div><textarea rows=10 cols=80>Array
(
 [scheme] => http
 [host] => my.phigita.net
 [path] => /media/one-view/494/h-returnImageFile?size=800
)
</textarea></div>

<div>action: display</div>

<div><textarea rows=10 cols=80>Array
(
 [ADD] => allow
 [MODIFY] => allow
 [DELETE] => allow
 [PASSWORD] => fnpassword
 [image] => http://my.phigita.net/media/one-view/494/h-returnImageFile?size=800
 [action] => display
 [width] => 500
 [height] => 333
 [alt] => Teddy and the Tree
 [style] => 
 [timestamp] => 2007-11-26T20:23:04Z
 [url_parts] => Array
        (
	 [scheme] => http
	 [host] => my.phigita.net
	 [path] => /media/one-view/494/h-returnImageFile?size=800
        )

 [image_path] => /var/www/sites/fotonotes.net/docs/test_images/teddyandthetree.jpg
)
</textarea></div>

<div>action: display 
image: http://my.phigita.net/media/one-view/494/h-returnImageFile?size=800</div>

<div>FNRetrieveJPEGHeader called & image is http://my.phigita.net/media/one-view/494/h-returnImageFile?size=800</div>

<div><textarea rows=10 cols=80>Array
(
 [0] => 500
 [1] => 333
 [2] => 2
 [3] => width="500" height="333"
 [bits] => 8
 [channels] => 3
 [mime] => image/jpeg
)
</textarea></div>

<div><textarea rows=10 cols=80></textarea></div>
displayHTML##
<!--module_fotonotesmod-->
<div id="fn-canvas-id-http://fotonotes.net/docs/test_images/teddyandthetree.jpg" class="fn-canvas fn-container-active" style="width: 500px; height: 353px;">
<div id="unique-id-http://fotonotes.net/docs/test_images/teddyandthetree.jpg" class="fn-container fn-container-active" style="width: 500px; height: 333px; top:20px; left:0px;">
<img src="http://my.phigita.net/media/one-view/494/h-returnImageFile?size=800" width="500" height="333" alt="Teddy and the Tree" style="" />
<span class="fn-scalefactor" title="1"></span>

<!-- ******* ANNOTATION 0 : Teddy was showing me around some of the land nearby his house. ********* -->
<div class="fn-area" style="left: 278px; top: 203px; width: 54px; height: 117px; border-color: ;">  
<div class="fn-note">
<span class="fn-note-created"></span>
<span class="fn-note-title">Teddy</span>
<span class="fn-note-content">Teddy was showing me around some of the land nearby his house.</span>
<span class="fn-note-author"></span>
<span class="fn-note-userid" style="display:none;"></span>
<span class="fn-note-id" title="http://127.0.0.1/eclipse_workspace/fnclient-0.5.0e1/trunk/test_images/f9507334d87d702beb45dd5a6b094425@teddyandthetree.jpg"></span>
</div>
<div class="fn-area-innerborder-left"></div>
<div class="fn-area-innerborder-right"></div>
<div class="fn-area-innerborder-top"></div>
<div class="fn-area-innerborder-bottom"></div>

</div>
<!-- end fn-area -->


<!-- ******* ANNOTATION 1 : Even the small ones are beautiful. ********* -->
<div class="fn-area" style="left: 99px; top: 2px; width: 171px; height: 286px; border-color: ;">  
<div class="fn-note">
<span class="fn-note-created"></span>
<span class="fn-note-title">Redwood</span>
<span class="fn-note-content">Even the small ones are beautiful.</span>
<span class="fn-note-author"></span>
<span class="fn-note-userid" style="display:none;"></span>
<span class="fn-note-id" title="http://127.0.0.1/eclipse_workspace/fnclient-0.6.0/trunk/docs/test_images/6a8257290c4ba0f3800e1af6d08f55c1@teddyandthetree.jpg"></span>
</div>
<div class="fn-area-innerborder-left"></div>
<div class="fn-area-innerborder-right"></div>
<div class="fn-area-innerborder-top"></div>
<div class="fn-area-innerborder-bottom"></div>

</div>
<!-- end fn-area -->

<div class="fn-controlbar fn-controlbar-active">
<!--span class="fn-controlbar-logo"></span-->
<span class="fn-controlbar-credits"></span>
<span class="fn-controlbar-del-inactive"></span>
<span class="fn-controlbar-edit-inactive"></span>
<span class="fn-controlbar-add-inactive"></span>
<span class="fn-controlbar-toggle-inactive"></span>

</div>

<form class="fn-editbar fn-editbar-inactive" name="fn_editbar" id="fn_editbar">



<!--div class="fn-editbar-fields">(other stuff here)</div-->

<div class="fn-editbar-fields">

<label>TITLE:</label><br />

<label><input type="input" class="fn-editbar-title" name="title" value="default" /></label>

<label><input type="hidden" class="fn-editbar-author" name="author" value="/></label>

    <label><input type="hidden" class="fn-editbar-userid" name="userid" value=""></label>

    <label><input type="hidden" class="fn-editbar-entry_id" name="entry_ID" value="http://127.0.0.1/eclipse_workspace/fnclient-0.6.0/trunk/docs/test_images/6a8257290c4ba0f3800e1af6d08f55c1@teddyandthetree.jpg"></label>

    <label><input type="hidden" class="fn-editbar-border-color" name="border_color" value="#FE0000"

 /></label>

  </div>

  

  <div class="fn-editbar-fields">

  <label>CONTENT:</label><br />

<label><textarea class="fn-editbar-content" name="content"></textarea></label>

  </div>

  <div class="fn-editbar-fields">

  <span class="fn-editbar-ok"></span>

<span class="fn-editbar-cancel"></span>

</div>

 </form>

 

</div>

</div><!--close fn-canvas-->

<!--module_fotonotesmod-->

##

<div>Done.</div>
}