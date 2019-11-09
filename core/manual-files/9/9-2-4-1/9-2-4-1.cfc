<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
<!DOCTYPE html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
<!--[if IE 7]> <html class="no-js lt-ie9 lt-ie8" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
<!--[if IE 8]> <html class="no-js lt-ie9" xmlns="http://www.w3.org/1999/xhtml"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" xmlns="http://www.w3.org/1999/xhtml"> <!--<![endif]-->
<head>
<title>
jQuery Parallax Slider Plug-in Examples
</title>
<meta charset="utf-8" />
<link rel="stylesheet" type="text/css" href="/z/javascript/jquery/jquery-parallax-slider/jquery.parallax-slider.css" />
<style>
/* <![CDATA[ */
##sliderPrev, ##sliderNext{display:none;background-color:##900; color:##FFF; z-index:100; position:relative;width:40px; text-align:center; font-size:24px; float:left; padding:10px;  cursor:pointer;text-decoration:none;}
##sliderPrev:hover, ##sliderNext:hover{ background-color:##C00;}
##sliderPrev2, ##sliderNext2{display:none;background-color:##900; color:##FFF; z-index:100; position:relative;width:40px; text-align:center; font-size:24px; float:left; padding:10px;  cursor:pointer;text-decoration:none;}
##sliderPrev2:hover, ##sliderNext2:hover{ background-color:##C00;}
##sliderPrev3, ##sliderNext3{display:none;background-color:##900; color:##FFF; z-index:100; position:relative;width:40px; text-align:center; font-size:24px; float:left; padding:10px;  cursor:pointer;text-decoration:none;}
##sliderPrev3:hover, ##sliderNext3:hover{ background-color:##C00;}
/* ]]> */
</style>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="/z/javascript/jquery/jquery-parallax-slider/jquery.parallax-slider.js"></script>
<script src="/z/javascript/jquery/jquery.animate-colors.js"></script>
<script src="/z/javascript/jquery/jquery.easing.1.3.js"></script>

<script>
/* <![CDATA[ */

$(document).ready(function(){
	var c={
		prev:$("##sliderPrev"),
		next:$("##sliderNext"),
		transition:'horizontal', 
		debug:false
	}
	//$("##sliderContainer").hide();
	var p=$("##sliderContainer").parallaxSlider(c);
	c={
		prev:$("##sliderPrev2"),
		next:$("##sliderNext2"),
		transition:'vertical', 
		debug:false,
		slideBeginCallback:function(slideObj){
			if(typeof slideObj.originalBackgroundColor == "undefined"){
				slideObj.originalBackgroundColor=slideObj.style.backgroundColor;
			}
			$(slideObj).css("background-color", "##000").animate({backgroundColor:slideObj.originalBackgroundColor}, {duration:500, queue:false});
		},
		slideEndCallback:function(slideObj){
			$(slideObj).css("background-color", slideObj.originalBackgroundColor).animate({backgroundColor:"##000"}, {duration:500, queue:false});
				
		}
	}
	//$(c.container).hide();
	var p=$("##sliderContainer2").parallaxSlider(c);
	var c={
		prev:$("##sliderPrev3"),
		next:$("##sliderNext3"),
		transition:'crossfade', 
		debug:false,
		autoplay:false
	}
	//$("##sliderContainer3").hide();
	var p=$("##sliderContainer3").parallaxSlider(c);
	
	
});
/* ]]> */
</script> 
</head>
<body>
<div style="padding-left:2%; padding-top:10px; width:95%; min-width:900px; float:left;">
<h1>jQuery Parallax Slider Plug-in Examples</h1>
<p>Below are 3 instances of the <a href="https://www.jetendo.com/z/admin/manual/view/9.2.4/jquery-parallax-slider.html" class="zNoContentTransition" title="Visit the project home page">jQuery Parallax Slider Plug-in</a> that demonstrate some of its features.</p>
<p>Please download the source files instead of hot-linking them.</p>
<h2>This slider has a different slide transition effect set for each slide</h2>
<div id="sliderContainer" class="zPSlideContainer" style="width:100%; height:300px;position:relative; float:left; overflow:hidden; background-color:##000;">
    <div class="zPSlideSlider" style="float:left;width:100%;position:relative;">
      <div class="zPSlide" data-config="{transition:'vertical',begin:{duration:5000}}" style="position:relative;width:100%; height:300px; left:0px; top:0px;  background-color:##060;">
        <div class="zPSlideAnimatedBackground" data-config="{durationX:1000, animateX:136, animateY:136}" data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasmad.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; height:300px;"></div>
        <div class="zPSlideAnimatedBackground" data-config="{durationX:100, animateX:200}"  data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasma.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; height:121px;margin-top:95px;"></div>
        <div class="zPSlideAnimatedBackground" data-config="{durationY:500, animateY:200}"  data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasmav.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; height:300px;"></div>
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:300px; top:50px; width:100px; height:20px; background-color:##900;"  data-config="{begin:{opacity:0, left:-100, top:0, duration:1000}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:50px; top:200px; width:50px; height:100px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:50, delay:500, duration:700}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:150px; top:120px; width:70px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:200, delay:1000, duration:500}, end:{opacity:0, left:0, top:0}}"></div>
        </div>
      </div>
      <div class="zPSlide" data-config="{transition:'horizontal',begin:{duration:5000}}" style="position:relative;width:100%; height:300px; left:0px; top:0px; background-color:##006;">
        <div class="zPSlideAnimatedBackground" data-config="{type:'transition',duration:400, animateX:'100%'}" data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasma.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; margin-top:95px; height:121px;"></div>
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style="z-index:1001; left:200px; top:200px; width:20px; height:50px; background-color:##900;" data-config="{begin:{opacity:0, left:-100, top:50, delay:1000, duration:1000}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:0px; top:70px; width:350px; font-size:48px; line-height:48px; color:##FFF;" data-config="{begin:{opacity:0, left:-100, top:0, delay:500, duration:700}, end:{opacity:0, left:0, top:0}}">Any HTML can be animated</div>
          <div class="zPSlideElement" style="z-index:1003; left:300px; top:130px; width:250px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:100, duration:500}, end:{opacity:0, left:0, top:0}}"></div>
        </div>
      </div>
      <div class="zPSlide" data-config="{transition:'crossfade',begin:{duration:5000}, end:{duration:1000}}" style="position:relative;width:100%; left:0px; top:0px; height:300px; background-color:##600;">
        <div class="zPSlideAnimatedBackground" data-config="{durationX:500, animateY:200}"  data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasmav.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; height:300px;"></div>
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:200px; top:100px; width:50px; height:50px; background-color:##900;" data-config="{begin:{opacity:0, left:-100, top:0, delay:500, duration:1000}, end:{opacity:0, left:100, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:30px; top:100px; width:50px; height:50px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:0, duration:700}, end:{opacity:0, left:-50, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:300px; top:30px; width:50px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:0, duration:1000}, end:{opacity:0, left:200, top:0}}"></div>
        </div>
      </div>
    </div>
  </div>
  <a href="##" id="sliderPrev" style="margin-top:-170px; margin-left:5%;">&lt;</a> <a href="##" id="sliderNext" style="margin-top:-170px; float:right;margin-right:5%;">&gt;</a>
</div>
<div style="padding-left:2%; padding-top:10px;padding-bottom:10px; width:95%; min-width:900px; float:left;">
<h2>Slide vertically and animate background color with the <a href="http://www.bitstorm.org/jquery/color-animation/" target="_blank">jquery Color animation plugin</a> using custom callback functions</h2>
  <div id="sliderContainer2" class="zPSlideContainer" style="width:100%; height:300px;position:relative; float:left; overflow:hidden; background-color:##000;">
    <div class="zPSlideSlider" style="float:left;width:100%;position:relative;">
      <div class="zPSlide" data-config="{begin:{duration:5000}}" style="position:relative;width:100%; height:300px; left:0px; top:0px;  background-color:##060;">
        
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:300px; top:50px; width:100px; height:20px; background-color:##900;"  data-config="{begin:{opacity:0, left:-100, top:0, duration:1000}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:50px; top:200px; width:50px; height:100px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:50, delay:500, duration:700}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:150px; top:120px; width:70px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:200, delay:1000, duration:500}, end:{opacity:0, left:0, top:0}}"></div>
        </div>
      </div>
      <div class="zPSlide" data-config="{begin:{duration:5000}}" style="position:relative;width:100%; height:300px; left:0px; top:0px; background-color:##006;">
        
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:200px; top:200px; width:20px; height:50px; background-color:##900;" data-config="{begin:{opacity:0, left:-100, top:50, delay:1000, duration:1000}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:100px; top:70px; width:50px; height:50px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:0, delay:500, duration:700}, end:{opacity:0, left:0, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:300px; top:130px; width:250px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:100, duration:500}, end:{opacity:0, left:0, top:0}}"></div>
        </div>
      </div>
      <div class="zPSlide" data-config="{begin:{duration:5000} }" style="position:relative;width:100%; left:0px; top:0px; height:300px; background-color:##600;">
        
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:200px; top:100px; width:50px; height:50px; background-color:##900;" data-config="{begin:{opacity:0, left:-100, top:0, delay:500, duration:1000}, end:{opacity:0, left:100, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:30px; top:100px; width:50px; height:50px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:0, duration:700}, end:{opacity:0, left:-50, top:0}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:300px; top:30px; width:50px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:0, duration:1000}, end:{opacity:0, left:200, top:0}}"></div>
        </div>
      </div> 
    </div>
  </div>
  <a href="##" id="sliderPrev2" style="margin-top:-170px; margin-left:5%;">&lt;</a> <a href="##" id="sliderNext2" style="margin-top:-170px; float:right;margin-right:5%;">&gt;</a> </div>
  
<div style="padding-left:2%; padding-top:10px;padding-bottom:50px; width:95%; min-width:900px; float:left;">
<h2>Crossfade with autoplay disabled.  Click the navigation button to transition the slides manually.  Using the <a href="https://github.com/gdsmith/jquery.easing" target="_blank">jQuery easing plugin</a>.</h2>
  <div id="sliderContainer3" class="zPSlideContainer" style="width:100%; height:300px;position:relative; float:left; overflow:hidden; background-color:##000;">
    <div class="zPSlideSlider" style="float:left;width:100%;position:relative;">
      <div class="zPSlide" data-config="{begin:{duration:3000},end:{duration:3000, easing:'easeOutSine'}}" style="position:relative;width:100%; height:300px; left:0px; top:0px; background-color:##006;">
        <div class="zPSlideAnimatedBackground" data-config="{durationX:2000, animateX:200, easingX:'easeOutElastic'}"  data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasma.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; margin-top:95px; height:121px;"></div>
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:200px; top:200px; width:20px; height:50px; background-color:##900;" data-config="{begin:{opacity:0, left:-100, top:50, delay:1000, duration:1000, easing:'easeInOutBack'}, end:{opacity:0, left:0, top:0, easing:'easeInBounce', duration:2000}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:100px; top:70px; width:50px; height:50px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:0, delay:500, duration:700, easing:'easeInOutBack'}, end:{opacity:0, left:0, top:0, easing:'easeInBounce', duration:2000}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:300px; top:130px; width:250px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:100, duration:500, easing:'easeInOutBack'}, end:{opacity:0, left:0, top:0, easing:'easeInBounce', duration:2000}}"></div>
        </div>
      </div>
      <div class="zPSlide" data-config="{begin:{duration:3000},end:{duration:3000, easing:'easeOutCirc'}}" style="position:relative;width:100%; height:300px; left:0px; top:0px;  background-color:##060;">
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:300px; top:50px; width:100px; height:20px; background-color:##900;"  data-config="{begin:{opacity:0, left:-100, top:0, duration:2000, easing:'easeInOutBounce'}, end:{opacity:0, left:0, top:0, easing:'easeInBounce', duration:2000}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:50px; top:200px; width:50px; height:100px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:50, delay:500, duration:700, easing:'easeInSine'}, end:{opacity:0, left:0, top:0, easing:'easeInBounce', duration:2000}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:150px; top:120px; width:70px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:200, delay:1000, duration:500, easing:'easeInCubic'}, end:{opacity:0, left:0, top:0, easing:'easeInBounce', duration:2000}}"></div>
        </div>
      </div>
      <div class="zPSlide" data-config="{begin:{duration:3000},end:{duration:3000, easing:'easeOutExpo'}}" style="position:relative;width:100%; left:0px; top:0px; height:300px; background-color:##600;">
        <div class="zPSlideAnimatedBackground" data-config="{durationY:1000, animateY:2000, easingY:'easeOutExpo'}"  data-background-image="/z/javascript/jquery/jquery-parallax-slider/examples/plasmav.png" style=" background-repeat:repeat; background-position:0px 0px; width:100%; height:300px;"></div>
        <div class="zPSlideCenter" style="width:600px; height:300px; margin:0 auto;position:relative;">
          <div class="zPSlideElement" style=" z-index:1001; left:200px; top:100px; width:50px; height:50px; background-color:##900;" data-config="{begin:{opacity:0, left:-100, top:0, delay:500, duration:1000, easing:'easeOutElastic'}, end:{opacity:0, left:100, top:0, easing:'easeInBounce', duration:2000}}"></div>
          <div class="zPSlideElement" style="z-index:1002; left:30px; top:100px; width:50px; height:50px; background-color:##090;" data-config="{begin:{opacity:0, left:-100, top:0, duration:700, easing:'easeOutElastic'}, end:{opacity:0, left:-50, top:0, easing:'easeInBounce', duration:2000}}"></div>
          <div class="zPSlideElement" style="z-index:1003; left:300px; top:30px; width:50px; height:50px; background-color:##009;" data-config="{begin:{opacity:0, left:-100, top:0, duration:1000, easing:'easeOutElastic'}, end:{opacity:0, left:200, top:0, easing:'easeInBounce', duration:2000}}"></div>
        </div>
      </div>
    </div>
  </div>
  <a href="##" id="sliderPrev3" style="margin-top:-170px; margin-left:5%;">&lt;</a> <a href="##" id="sliderNext3" style="margin-top:-170px; float:right;margin-right:5%;">&gt;</a> </div>
</body>
</html>
<cfscript>
if(request.zos.originalURL DOES NOT CONTAIN "/z/server-manager/"){
  request.zos.functions.zabort();
}
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>