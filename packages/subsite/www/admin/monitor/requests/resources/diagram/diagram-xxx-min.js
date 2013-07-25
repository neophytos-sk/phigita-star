
var _N_Dia=0,_N_Bar=0,_N_Box=0,_N_Dot=0,_N_Pix=0,_N_Line=0,_N_Area=0,_N_Arrow=0,_N_Pie=0,_zIndex=0;var _dSize=(navigator.appName=="Microsoft Internet Explorer")?1:-1;if(navigator.userAgent.search("Opera")>=0)_dSize=-1;var _IE=0;if(_dSize==1)
{_IE=1;if(window.document.documentElement.clientHeight)_dSize=-1;}
var _nav4=(document.layers)?1:0;var _DiagramTarget=window;var _BFont="font-family:Verdana;font-weight:bold;font-size:10pt;line-height:13pt;"
var _PathToScript="./resources/diagram/";if(document.layers)document.write("<script language=\"JavaScript\" src=\""+_PathToScript+"diagram_nav.js\"></script>");else document.write("<script language=\"JavaScript\" src=\""+_PathToScript+"diagram_dom.js\"></script>");function Diagram()
{this.xtext="";this.ytext="";this.title="";this.XScale=1;this.YScale=1;this.XScalePosition="bottom";this.YScalePosition="left";this.Font="font-family:Verdana;font-weight:normal;font-size:10pt;line-height:13pt;";this.ID="Dia"+_N_Dia;_N_Dia++;_zIndex++;this.zIndex=_zIndex;this.logsub=new Array(0.301,0.477,0.602,0.699,0.778,0.845,0.903,0.954);this.SetFrame=_SetFrame;this.SetBorder=_SetBorder;this.SetText=_SetText;this.SetGridColor=_SetGridColor;this.SetXGridColor=_SetXGridColor;this.SetYGridColor=_SetYGridColor;this.ScreenX=_ScreenX;this.ScreenY=_ScreenY;this.RealX=_RealX;this.RealY=_RealY;this.XGrid=new Array(3);this.GetXGrid=_GetXGrid;this.YGrid=new Array(3);this.GetYGrid=_GetYGrid;this.XGridDelta=0;this.YGridDelta=0;this.XSubGrids=0;this.YSubGrids=0;this.SubGrids=0;this.XGridColor="";this.YGridColor="";this.XSubGridColor="";this.YSubGridColor="";this.MaxGrids=0;this.DateInterval=_DateInterval;this.Draw=_Draw;this.SetVisibility=_SetVisibility;this.SetTitle=_SetTitle;this.Delete=_Delete;return(this);}
function _SetFrame(theLeft,theTop,theRight,theBottom)
{this.left=theLeft;this.right=theRight;this.top=theTop;this.bottom=theBottom;}
function _SetBorder(theLeftX,theRightX,theBottomY,theTopY)
{this.xmin=theLeftX;this.xmax=theRightX;this.ymin=theBottomY;this.ymax=theTopY;}
function _SetText(theScaleX,theScaleY,theTitle)
{this.xtext=theScaleX;this.ytext=theScaleY;this.title=theTitle;}
function _SetGridColor(theGridColor,theSubGridColor)
{this.XGridColor=theGridColor;this.YGridColor=theGridColor;if((theSubGridColor)||(theSubGridColor==""))
{this.XSubGridColor=theSubGridColor;this.YSubGridColor=theSubGridColor;}}
function _SetXGridColor(theGridColor,theSubGridColor)
{this.XGridColor=theGridColor;if((theSubGridColor)||(theSubGridColor==""))
this.XSubGridColor=theSubGridColor;}
function _SetYGridColor(theGridColor,theSubGridColor)
{this.YGridColor=theGridColor;if((theSubGridColor)||(theSubGridColor==""))
this.YSubGridColor=theSubGridColor;}
function _ScreenX(theRealX)
{return(Math.round((theRealX-this.xmin)/(this.xmax-this.xmin)*(this.right-this.left)+this.left));}
function _ScreenY(theRealY)
{return(Math.round((this.ymax-theRealY)/(this.ymax-this.ymin)*(this.bottom-this.top)+this.top));}
function _RealX(theScreenX)
{return(this.xmin+(this.xmax-this.xmin)*(theScreenX-this.left)/(this.right-this.left));}
function _RealY(theScreenY)
{return(this.ymax-(this.ymax-this.ymin)*(theScreenY-this.top)/(this.bottom-this.top));}
function _sign(rr)
{if(rr<0)return(-1);else return(1);}
function _DateInterval(vv)
{var bb=140*24*60*60*1000;this.SubGrids=4;if(vv>=bb)
{bb=8766*60*60*1000;if(vv<bb)
return(bb/12);if(vv<bb*2)
return(bb/6);if(vv<bb*5/2)
{this.SubGrids=6;return(bb/4);}
if(vv<bb*5)
{this.SubGrids=6;return(bb/2);}
if(vv<bb*10)
return(bb);if(vv<bb*20)
return(bb*2);if(vv<bb*50)
{this.SubGrids=5;return(bb*5);}
if(vv<bb*100)
{this.SubGrids=5;return(bb*10);}
if(vv<bb*200)
return(bb*20);if(vv<bb*500)
{this.SubGrids=5;return(bb*50);}
this.SubGrids=5;return(bb*100);}
bb/=2;if(vv>=bb){this.SubGrids=7;return(bb/5);}
bb/=2;if(vv>=bb){this.SubGrids=7;return(bb/5);}
bb/=7;bb*=4;if(vv>=bb)return(bb/5);bb/=2;if(vv>=bb)return(bb/5);bb/=2;if(vv>=bb)return(bb/5);bb/=2;if(vv>=bb)return(bb/5);bb*=3;bb/=5;if(vv>=bb){this.SubGrids=6;return(bb/6);}
bb/=2;if(vv>=bb){this.SubGrids=6;return(bb/6);}
bb*=2;bb/=3;if(vv>=bb)return(bb/6);bb/=2;if(vv>=bb)return(bb/6);bb/=2;if(vv>=bb){this.SubGrids=6;return(bb/6);}
bb/=2;if(vv>=bb){this.SubGrids=5;return(bb/6);}
bb*=2;bb/=3;if(vv>=bb){this.SubGrids=5;return(bb/6);}
bb/=3;if(vv>=bb){this.SubGrids=5;return(bb/4);}
bb/=2;if(vv>=bb)return(bb/5);bb/=2;if(vv>=bb)return(bb/5);bb*=3;bb/=2;if(vv>=bb){this.SubGrids=6;return(bb/6);}
bb/=2;if(vv>=bb){this.SubGrids=5;return(bb/6);}
bb*=2;bb/=3;if(vv>=bb){this.SubGrids=5;return(bb/6);}
bb/=3;if(vv>=bb){this.SubGrids=5;return(bb/4);}
bb/=2;if(vv>=bb)return(bb/5);return(bb/10);}
function _DayOfYear(dd,mm,yy)
{DOM=new Array(31,28,31,30,31,30,31,31,30,31,30,31);var ii,nn=dd;for(ii=0;ii<mm-1;ii++)nn+=DOM[ii];if((mm>2)&&(yy%4==0))nn++;return(nn);}
function _GetKWT(dd,mm,yy)
{var ss=new Date(yy,0,1);var ww=ss.getDay();ww=(ww+2)%7-3;ww+=(_DayOfYear(dd,mm,yy)-1);if(ww<0)return(_GetKWT(24+dd,12,yy-1));if((mm==12)&&(dd>28))
{if(ww%7+29<=dd)return("01/"+eval(ww%7+1));}
ss=Math.floor(ww/7+1);if(ss<10)ss="0"+ss;return(ss+"/"+eval(ww%7+1));}
function _DateFormat(vv,ii,ttype)
{var yy,mm,dd,hh,nn,ss,vv_date=new Date(vv);Month=new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");Weekday=new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");if(ii>15*24*60*60*1000)
{if(ii<365*24*60*60*1000)
{vv_date.setTime(vv+15*24*60*60*1000);yy=vv_date.getUTCFullYear()%100;if(yy<10)yy="0"+yy;mm=vv_date.getUTCMonth()+1;if(ttype==5);if(ttype==4)return(Month[mm-1]);if(ttype==3)return(Month[mm-1]+" "+yy);return(mm+"/"+yy);}
vv_date.setTime(vv+183*24*60*60*1000);yy=vv_date.getUTCFullYear();return(yy);}
vv_date.setTime(vv);yy=vv_date.getUTCFullYear();mm=vv_date.getUTCMonth()+1;dd=vv_date.getUTCDate();ww=vv_date.getUTCDay();hh=vv_date.getUTCHours();nn=vv_date.getUTCMinutes();ss=vv_date.getUTCSeconds();if(ii>=86400000)
{if(ttype==5);if(ttype==4)return(Weekday[ww]);if(ttype==3)return(mm+"/"+dd);return(dd+"."+mm+".");}
if(ii>=21600000)
{if(hh==0)
{if(ttype==5);if(ttype==4)return(Weekday[ww]);if(ttype==3)return(mm+"/"+dd);return(dd+"."+mm+".");}
else
{if(ttype==5);if(ttype==4)return((hh<=12)?hh+"am":hh%12+"pm");if(ttype==3)return((hh<=12)?hh+"am":hh%12+"pm");return(hh+":00");}}
if(ii>=60000)
{if(nn<10)nn="0"+nn;if(ttype==5);if(ttype==4)return((hh<=12)?hh+"."+nn+"am":hh%12+"."+nn+"pm");if(nn=="00")nn="";else nn=":"+nn;if(ttype==3)return((hh<=12)?hh+nn+"am":hh%12+nn+"pm");if(nn=="")nn=":00";return(hh+nn);}
if(ii>=1000)
{if(nn<10)nn="0"+nn;if(nn=="00")nn="";else nn=":"+nn;if(ss<10)ss="0"+ss;if(ss=="00")ss="";else ss=":"+ss;if(ttype==5);if(ttype==4)return hh+nn+ss;if(ttype==3)return((hh<=12)?hh+nn+"am":hh%12+nn+"pm");return(hh+nn);}
if(ss<10)ss="0"+ss;return(nn+":"+ss);}
function _GetXGrid()
{var x0,i,j,l,x,r,dx,xr,invdifx,deltax;dx=(this.xmax-this.xmin);if(Math.abs(dx)>0)
{invdifx=(this.right-this.left)/(this.xmax-this.xmin);if((this.XScale==1)||(isNaN(this.XScale)))
{r=1;while(Math.abs(dx)>=100){dx/=10;r*=10;}
while(Math.abs(dx)<10){dx*=10;r/=10;}
if(Math.abs(dx)>=50){this.SubGrids=5;deltax=10*r*_sign(dx);}
else
{if(Math.abs(dx)>=20){this.SubGrids=5;deltax=5*r*_sign(dx);}
else{this.SubGrids=4;deltax=2*r*_sign(dx);}}}
else deltax=this.DateInterval(Math.abs(dx))*_sign(dx);if(this.XGridDelta!=0)deltax=this.XGridDelta;if(this.XSubGrids!=0)this.SubGrids=this.XSubGrids;x=Math.floor(this.xmin/deltax)*deltax;i=0;this.XGrid[1]=deltax;if(deltax!=0)this.MaxGrids=Math.floor(Math.abs((this.xmax-this.xmin)/deltax))+2;else this.MaxGrids=0;for(j=this.MaxGrids;j>=-1;j--)
{xr=x+j*deltax;x0=Math.round(this.left+(-this.xmin+xr)*invdifx);if((x0>=this.left)&&(x0<=this.right))
{if(i==0)this.XGrid[2]=xr;this.XGrid[0]=xr;i++;}}}
return(this.XGrid);}
function _GetYGrid()
{var y0,i,j,l,y,r,dy,yr,invdify,deltay;dy=this.ymax-this.ymin;if(Math.abs(dy)>0)
{invdify=(this.bottom-this.top)/(this.ymax-this.ymin);if((this.YScale==1)||(isNaN(this.YScale)))
{r=1;while(Math.abs(dy)>=100){dy/=10;r*=10;}
while(Math.abs(dy)<10){dy*=10;r/=10;}
if(Math.abs(dy)>=50){this.SubGrids=5;deltay=10*r*_sign(dy);}
else
{if(Math.abs(dy)>=20){this.SubGrids=5;deltay=5*r*_sign(dy);}
else{this.SubGrids=4;deltay=2*r*_sign(dy);}}}
else deltay=this.DateInterval(Math.abs(dy))*_sign(dy);if(this.YGridDelta!=0)deltay=this.YGridDelta;if(this.YSubGrids!=0)this.SubGrids=this.YSubGrids;y=Math.floor(this.ymax/deltay)*deltay;this.YGrid[1]=deltay;i=0;if(deltay!=0)this.MaxGrids=Math.floor(Math.abs((this.ymax-this.ymin)/deltay))+2;else this.MaxGrids=0;for(j=-1;j<=this.MaxGrids;j++)
{yr=y-j*deltay;y0=Math.round(this.top+(this.ymax-yr)*invdify);if((y0>=this.top)&&(y0<=this.bottom))
{if(i==0)this.YGrid[2]=yr;this.YGrid[0]=yr;i++;}}}
return(this.YGrid);}
function _nvl(vv,rr)
{if(vv==null)return(rr);var ss=String(vv);while(ss.search("'")>=0)ss=ss.replace("'","&#39;");return(ss);}
function _cursor(aa)
{if(aa)
{if(_dSize==1)return("cursor:hand;");else return("cursor:pointer;");}
return("");}
function _GetArrayMin(aa)
{var ii,mm=aa[0];for(ii=1;ii<aa.length;ii++)
{if(mm>aa[ii])mm=aa[ii];}
return(mm);}
function _GetArrayMax(aa)
{var ii,mm=aa[0];for(ii=1;ii<aa.length;ii++)
{if(mm<aa[ii])mm=aa[ii];}
return(mm);}
function _IsImage(ss)
{if(!ss)return(false);var tt=String(ss).toLowerCase().split(".");if(tt.length!=2)return(false);switch(tt[1])
{case"gif":return(true);case"png":return(true);case"jpg":return(true);case"jpg":return(true);return(false);}}
