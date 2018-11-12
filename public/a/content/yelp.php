<?php

//
// From https://www.yelp.com/developers/documentation/v3/business_search
//

/*
COMMUNITY INFORMATION
list: https://www.yelp.com/developers/documentation/v3/all_category_list

Business Name
Address
Address2
Phone

*/
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("x_ajax_id: z_yelp_api_ajax_id");
$debug=false;
if(isset($_GET["cat"])){
	$cat = $_GET["cat"];
}else if(isset($_GET["category"])){
	$cat = $_GET["category"];
}else if(isset($_GET["term"])){
	$cat = $_GET["term"];
}else{
	echo "Invalid Request.";
	exit;
}
$location = "";
if ( isset( $_GET['location'] ) ) {
	$location = $_GET['location'];
}
else {
	if ( isset( $_GET['lat'] ) ) {
		$latitude = $_GET['lat'];
	}
	if ( isset( $_GET['latitude'] ) ) {
		$latitude = $_GET['latitude'];
	}
	if ( isset( $_GET['long'] ) ) {
		$longitude = $_GET['longitude'];
	}
	if ( isset( $_GET['longitude'] ) ) {
		$longitude = $_GET['longitude'];
	}
	if($latitude == "undefined" || $longitude == "undefined"){
		echo "Invalid Request..";
		exit;
	}
	$location = $latitude ."," .$longitude;
}
if ( isset( $_GET['radius'] ) ) {
	$radius = $_GET['radius'] * 1600; // converted miles to square meters
} else{
	$radius = 1000;
}

if(isset($_GET["limit"])){
	$limit = $_GET["limit"];
}else{
	$limit = 10;
}
require_once ('oauth.php');

$token_secret = get_cfg_var("jetendo_yelp3_api_key");
if(!$debug){
	$ch = curl_init("https://api.yelp.com/v3/businesses/search?location=" .$location ."&term=" .$cat ."&radius=" .$radius ."&limit=" .$limit);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json' , "Authorization: Bearer " .$token_secret));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch,CURLOPT_TIMEOUT,5000);
 	$data = curl_exec($ch); // Yelp response
	curl_close($ch);
	if($data === FALSE){
		echo "Request failed";
		exit;
	}
 
}else{
	$data='{"region": {"span": {"latitude_delta": 0.16580477081981826, "longitude_delta": 0.13655685999998468}, "center": {"latitude": 28.493801895081901, "longitude": -81.525166600000006}}, "total": 170, "businesses": [{"is_claimed": false, "distance": 9927.1773505544334, "mobile_url": "http://m.yelp.com/biz/aloha-isle-lake-buena-vista-2", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 47, "name": "Aloha Isle", "snippet_image_url": "http://s3-media1.ak.yelpcdn.com/photo/yFeGOdHvr58j8SR7N1Vl5Q/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/aloha-isle-lake-buena-vista-2", "snippet_text": "- Get the Dole whip float with vanilla soft serve ice cream.\n- Refreshingly delicious and yummy and not too expensive (well compared to everything else at...", "image_url": "http://s3-media2.ak.yelpcdn.com/bphoto/pwNnXGWn0aTs7e209J2DNA/ms.jpg", "categories": [["Ice Cream \u0026 Frozen Yogurt", "icecream"]], "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "aloha-isle-lake-buena-vista-2", "is_closed": false, "location": {"city": "Lake Buena Vista", "display_address": ["Magic Kingdom / Adventureland", "1365 N Monorail Way", "Lake Buena Vista, FL 32830"], "geo_accuracy": 9, "postal_code": "32830", "country_code": "US", "address": ["Magic Kingdom / Adventureland", "1365 N Monorail Way"], "coordinate": {"latitude": 28.418436090163802, "longitude": -81.582505926489802}, "state_code": "FL"}}, {"is_claimed": true, "distance": 10607.57675543695, "mobile_url": "http://m.yelp.com/biz/axum-coffee-winter-garden", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 20, "name": "Axum Coffee", "snippet_image_url": "http://s3-media3.ak.yelpcdn.com/photo/VXEC68leBQUZGeoSqHQkOA/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/axum-coffee-winter-garden", "location": {"city": "Winter Garden", "display_address": ["146 W Plant St", "Winter Garden, FL 34787"], "geo_accuracy": 8, "postal_code": "34787", "country_code": "US", "address": ["146 W Plant St"], "coordinate": {"latitude": 28.565283300000001, "longitude": -81.587237900000005}, "state_code": "FL"}, "phone": "4076547900", "snippet_text": "I have yet to not enjoy a drink I\'ve had there and that\'s saying something.\n\nAxum is a bit out of the way for me, but I couldn\'t ignore all of the fans it...", "image_url": "http://s3-media3.ak.yelpcdn.com/bphoto/rZcUrTPtpJzdY1XuTs5yCA/ms.jpg", "categories": [["Coffee \u0026 Tea", "coffee"]], "display_phone": "+1-407-654-7900", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "axum-coffee-winter-garden", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}, {"is_claimed": false, "distance": 2852.5275735360933, "mobile_url": "http://m.yelp.com/biz/fresh-market-orlando", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 28, "name": "Fresh Market", "snippet_image_url": "http://s3-media4.ak.yelpcdn.com/photo/8NK0K0AZKY-ScLFOolMkbg/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/fresh-market-orlando", "location": {"city": "Orlando", "display_address": ["5000 Dr Phillips Blvd", "Orlando, FL 32819"], "geo_accuracy": 8, "postal_code": "32819", "country_code": "US", "address": ["5000 Dr Phillips Blvd"], "coordinate": {"latitude": 28.491728299999998, "longitude": -81.492079000000004}, "state_code": "FL"}, "phone": "4072941516", "snippet_text": "I visited The Fresh Market on Conroy-Windermere Road today for the first time in about three years. I\'m not rich, so I can\'t afford to shop here regularly....", "image_url": "http://s3-media3.ak.yelpcdn.com/bphoto/JAJbieDVIoQUy9FMHYnuwA/ms.jpg", "categories": [["Grocery", "grocery"], ["Bakeries", "bakeries"], ["Health Markets", "healthmarkets"]], "display_phone": "+1-407-294-1516", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "fresh-market-orlando", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}, {"is_claimed": false, "distance": 7018.2778263551181, "mobile_url": "http://m.yelp.com/biz/house-blend-caf%C3%A9-ocoee-2", "rating_img_url": "http://s3-media1.ak.yelpcdn.com/assets/2/www/img/f1def11e4e79/ico/stars/v1/stars_5.png", "review_count": 11, "name": "House Blend Caf\u00e9", "snippet_image_url": "http://s3-media3.ak.yelpcdn.com/photo/VXEC68leBQUZGeoSqHQkOA/ms.jpg", "rating": 5.0, "url": "http://www.yelp.com/biz/house-blend-caf%C3%A9-ocoee-2", "location": {"city": "Ocoee", "display_address": ["10730 W Colonial D", "Ocoee, FL 34761"], "geo_accuracy": 8, "postal_code": "34761", "country_code": "US", "address": ["10730 W Colonial D"], "coordinate": {"latitude": 28.551145999999999, "longitude": -81.537006399999996}, "state_code": "FL"}, "phone": "4076567676", "snippet_text": "Great coffee and easily some of the best food I\'ve had a coffee shop makes this one a winner.\n\nThe bar for coffee shop food is pretty low, so I guess saying...", "image_url": "http://s3-media3.ak.yelpcdn.com/bphoto/VI08BoqRfklIRTDGe_Bveg/ms.jpg", "categories": [["Coffee \u0026 Tea", "coffee"]], "display_phone": "+1-407-656-7676", "rating_img_url_large": "http://s3-media3.ak.yelpcdn.com/assets/2/www/img/22affc4e6c38/ico/stars/v1/stars_large_5.png", "id": "house-blend-caf\u00e9-ocoee-2", "is_closed": false, "rating_img_url_small": "http://s3-media1.ak.yelpcdn.com/assets/2/www/img/c7623205d5cd/ico/stars/v1/stars_small_5.png"}, {"is_claimed": false, "distance": 6347.7966797595427, "mobile_url": "http://m.yelp.com/biz/whole-foods-market-orlando", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 80, "name": "Whole Foods Market", "snippet_image_url": "http://s3-media3.ak.yelpcdn.com/photo/Ym330jkoyBIuQy49BAKHAw/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/whole-foods-market-orlando", "location": {"city": "Orlando", "display_address": ["Phillips Crossing", "8003 Turkey Lake Rd", "Dr. Phillips", "Orlando, FL 32819"], "geo_accuracy": 8, "neighborhoods": ["Dr. Phillips"], "postal_code": "32819", "country_code": "US", "address": ["Phillips Crossing", "8003 Turkey Lake Rd"], "coordinate": {"latitude": 28.448239000000001, "longitude": -81.476384899999999}, "state_code": "FL"}, "phone": "4073557100", "snippet_text": "I HEART Whole Foods!  All Whole foods for that matter.  BUt I must admit this is one of the better ones.  Since most WF stores are similar the part that...", "image_url": "http://s3-media4.ak.yelpcdn.com/bphoto/GW6810Cvox0EHShTixETag/ms.jpg", "categories": [["Grocery", "grocery"], ["Health Markets", "healthmarkets"]], "display_phone": "+1-407-355-7100", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "whole-foods-market-orlando", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}, {"is_claimed": true, "distance": 6220.1182453790225, "mobile_url": "http://m.yelp.com/biz/achilles-art-and-cafe-coffee-shop-orlando-2", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 16, "name": "Achilles Art and Cafe Coffee Shop", "snippet_image_url": "http://s3-media3.ak.yelpcdn.com/photo/zyFW86aDONSAUpm1VUuaiA/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/achilles-art-and-cafe-coffee-shop-orlando-2", "location": {"city": "Orlando", "display_address": ["2869 Wilshire Dr", "Unit 103", "Orlando, FL 32835"], "geo_accuracy": 9, "postal_code": "32835", "country_code": "US", "address": ["2869 Wilshire Dr", "Unit 103"], "coordinate": {"latitude": 28.512493200000002, "longitude": -81.463095300000006}, "state_code": "FL"}, "phone": "4077047860", "snippet_text": "Favorite coffee shop in Orlando! Fantastic art decor, great atmosphere, delicious sandwhiches, a great variety of drinks - coffee, teas, beer, wine. and...", "image_url": "http://s3-media1.ak.yelpcdn.com/bphoto/fF-vC3L41maIXSUQDkbQ1w/ms.jpg", "categories": [["Coffee \u0026 Tea", "coffee"], ["Lounges", "lounges"], ["Hookah Bars", "hookah_bars"]], "display_phone": "+1-407-704-7860", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "achilles-art-and-cafe-coffee-shop-orlando-2", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}, {"is_claimed": true, "distance": 5439.5905012242538, "mobile_url": "http://m.yelp.com/biz/pinkberry-orlando", "rating_img_url": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/c2f3dd9799a5/ico/stars/v1/stars_4.png", "review_count": 46, "name": "Pinkberry", "snippet_image_url": "http://s3-media1.ak.yelpcdn.com/photo/kLO9QjdeUKPRMmZuvzSBPA/ms.jpg", "rating": 4.0, "url": "http://www.yelp.com/biz/pinkberry-orlando", "location": {"city": "Orlando", "display_address": ["7600 Dr Phillips Blvd", "The Marketplace At Dr Phillips", "Dr. Phillips", "Orlando, FL 32819"], "geo_accuracy": 5, "neighborhoods": ["Dr. Phillips"], "postal_code": "32819", "country_code": "US", "address": ["7600 Dr Phillips Blvd", "The Marketplace At Dr Phillips"], "coordinate": {"latitude": 28.460940000000001, "longitude": -81.476050000000001}, "state_code": "FL"}, "phone": "4073540890", "snippet_text": "Really good yoghurt ice cream! Build your own from scratch. Choose flavor and toppings. Any number of toppings - The sky\'s the limit! (2 is included)\n\nThe...", "image_url": "http://s3-media2.ak.yelpcdn.com/bphoto/3PcW7MTd8ZpRXiyy-kYklA/ms.jpg", "categories": [["Desserts", "desserts"], ["Ice Cream \u0026 Frozen Yogurt", "icecream"]], "display_phone": "+1-407-354-0890", "rating_img_url_large": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/ccf2b76faa2c/ico/stars/v1/stars_large_4.png", "id": "pinkberry-orlando", "is_closed": false, "rating_img_url_small": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/f62a5be2f902/ico/stars/v1/stars_small_4.png"}, {"is_claimed": false, "distance": 5439.5905012242538, "mobile_url": "http://m.yelp.com/biz/publix-orlando-8", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 14, "name": "Publix", "snippet_image_url": "http://s3-media3.ak.yelpcdn.com/photo/wr8eBrLL0_DZ7tNu8IqBHA/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/publix-orlando-8", "location": {"city": "Orlando", "display_address": ["7640 W Sand Lake Rd", "Plaza Venezia", "Dr. Phillips", "Orlando, FL 32819"], "geo_accuracy": 5, "neighborhoods": ["Dr. Phillips"], "postal_code": "32819", "country_code": "US", "address": ["7640 W Sand Lake Rd", "Plaza Venezia"], "coordinate": {"latitude": 28.460940000000001, "longitude": -81.476050000000001}, "state_code": "FL"}, "phone": "4072263360", "snippet_text": "Very well maintained Publix. The staff here is friendly and they actually smile at you. Keep up the good work guys!", "image_url": "http://s3-media4.ak.yelpcdn.com/bphoto/-HZz5_vcsiOskJ5U1EcVvg/ms.jpg", "categories": [["Grocery", "grocery"], ["Health Markets", "healthmarkets"], ["Drugstores", "drugstores"]], "display_phone": "+1-407-226-3360", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "publix-orlando-8", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}, {"is_claimed": false, "distance": 9125.353925151574, "mobile_url": "http://m.yelp.com/biz/monsta-lobsta-ocoee", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 14, "name": "Monsta Lobsta", "snippet_image_url": "http://s3-media3.ak.yelpcdn.com/photo/IW9P0OAmj1RH0SOf8jZp8g/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/monsta-lobsta-ocoee", "location": {"city": "Ocoee", "display_address": ["Ocoee, FL 34761"], "geo_accuracy": 4, "postal_code": "34761", "country_code": "US", "address": [], "coordinate": {"latitude": 28.569167700000001, "longitude": -81.543961899999999}, "state_code": "FL"}, "phone": "4074920350", "snippet_text": "Better lobster rolls than you can find in the Hamptons at half the price!!\n\nLARGE chunks of lobster just fall out of the buttery toasted bun.  I cry if some...", "image_url": "http://s3-media3.ak.yelpcdn.com/bphoto/hmr7MigQV9iGG93YKu-PSg/ms.jpg", "categories": [["Street Vendors", "streetvendors"]], "display_phone": "+1-407-492-0350", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "monsta-lobsta-ocoee", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}, {"is_claimed": false, "distance": 1382.0401518896736, "mobile_url": "http://m.yelp.com/biz/castellos-pizza-orlando", "rating_img_url": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count": 4, "name": "Castello\'s Pizza", "snippet_image_url": "http://s3-media4.ak.yelpcdn.com/photo/6pr79lAc6mVLKI35iR2WYA/ms.jpg", "rating": 4.5, "url": "http://www.yelp.com/biz/castellos-pizza-orlando", "location": {"city": "Orlando", "display_address": ["8947 Conroy Windermere Rd", "Orlando, FL 32835"], "geo_accuracy": 8, "postal_code": "32835", "country_code": "US", "address": ["8947 Conroy Windermere Rd"], "coordinate": {"latitude": 28.493709200000001, "longitude": -81.507825299999993}, "state_code": "FL"}, "phone": "4078760021", "snippet_text": "It\'s one of the best NY style pizza places in Orlando. I just wish delivered to my house.", "categories": [["Food Delivery Services", "fooddeliveryservices"], ["Pizza", "pizza"]], "display_phone": "+1-407-876-0021", "rating_img_url_large": "http://s3-media4.ak.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id": "castellos-pizza-orlando", "is_closed": false, "rating_img_url_small": "http://s3-media2.ak.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png"}]}';
}
$a=json_decode($data);
$error=json_last_error();
if($error != JSON_ERROR_NONE){
	throw new Exception("Yelp didn't return valid json: ".$error);
}
if(strpos($_SERVER['HTTP_HOST'], ".".get_cfg_var("jetendo_test_domain")) !== FALSE){
	$testserver=true;
}else{
	$testserver=false;
}

if($testserver){ 
     $domain=get_cfg_var("jetendo_test_admin_domain"); 
}else{ 
     $domain=get_cfg_var("jetendo_admin_domain"); 
} 
for($i=0;$i<count($a->businesses);$i++){
	$c=$a->businesses[$i];
	if(isset($c->rating)){
		$c->rating_img_url = $domain."/z/images/stars/stars".$c->rating.".png";
	}else{
		$c->rating_img_url=$domain."/z/a/s.gif";
	}
	$a->businesses[$i]=$c;
}
$data=json_encode($a);
echo $data;
exit;
?>