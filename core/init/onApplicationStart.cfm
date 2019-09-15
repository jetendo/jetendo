<cfoutput> 
<cffunction name="setupAppGlobals1" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var t3=0;
	var t9=0;		
	var ts=arguments.ss; 
	ts.tempTokenCache=structnew();
 
	ts.queryCache=structnew('soft');
	
	ts.robotThatHitSpamTrap=structnew();
	
	ts.mysqlSelectReservedNames=structnew();
	ts.mysqlSelectReservedNames.ALL=true;
	ts.mysqlSelectReservedNames.DISTINCT=true;
	ts.mysqlSelectReservedNames.DISTINCTROW=true;
	ts.mysqlSelectReservedNames.HIGH_PRIORITY=true;
	ts.mysqlSelectReservedNames.STRAIGHT_JOIN=true;
	ts.mysqlSelectReservedNames.SQL_SMALL_RESULT=true;
	ts.mysqlSelectReservedNames.SQL_BIG_RESULT=true;
	ts.mysqlSelectReservedNames.SQL_BUFFER_RESULT=true;
	ts.mysqlSelectReservedNames.SQL_CACHE=true;
	ts.mysqlSelectReservedNames.SQL_NO_CACHE=true;
	ts.mysqlSelectReservedNames.SQL_CACHE=true;
	ts.mysqlSelectReservedNames.SQL_CALC_FOUND_ROWS=true; 
	
	ts.mysqlDataTypeStruct=structnew();
	ts.mysqlDataTypeStruct["bigint_unsigned"]="cf_sql_char";
	ts.mysqlDataTypeStruct["bigint"]="cf_sql_char";
	ts.mysqlDataTypeStruct["mediumint"]="cf_sql_integer";
	ts.mysqlDataTypeStruct["mediumint_unsigned"]="cf_sql_integer";
	ts.mysqlDataTypeStruct["int"]="cf_sql_integer";
	ts.mysqlDataTypeStruct["int_unsigned"]="cf_sql_bigint";
	ts.mysqlDataTypeStruct["smallint_unsigned"]="cf_sql_smallint";
	ts.mysqlDataTypeStruct["smallint_signed"]="cf_sql_smallint";
	ts.mysqlDataTypeStruct["tinyint_unsigned"]="cf_sql_smallint";
	ts.mysqlDataTypeStruct["tinyint"]="cf_sql_tinyint";
	ts.mysqlDataTypeStruct["date"]="cf_sql_date";
	ts.mysqlDataTypeStruct["decimal"]="cf_sql_decimal";
	ts.mysqlDataTypeStruct["decimal_unsigned"]="cf_sql_decimal";
	ts.mysqlDataTypeStruct["bit"]="cf_sql_bit";
	ts.mysqlDataTypeStruct["bool"]="cf_sql_bit";
	ts.mysqlDataTypeStruct["blob"]="cf_sql_blob";
	ts.mysqlDataTypeStruct["char"]="cf_sql_char";
	ts.mysqlDataTypeStruct["double"]="cf_sql_double";
	ts.mysqlDataTypeStruct["precision"]="cf_sql_double";
	ts.mysqlDataTypeStruct["real"]="cf_sql_double";
	ts.mysqlDataTypeStruct["mediumblog"]="cf_sql_longvarbinary";
	ts.mysqlDataTypeStruct["longblog"]="cf_sql_longvarbinary";
	ts.mysqlDataTypeStruct["tinyblog"]="cf_sql_longvarbinary";
	ts.mysqlDataTypeStruct["longtext"]="cf_sql_longvarchar";
	ts.mysqlDataTypeStruct["text"]="cf_sql_longvarchar";
	ts.mysqlDataTypeStruct["mediumtext"]="cf_sql_longvarchar";
	ts.mysqlDataTypeStruct["numeric"]="cf_sql_numeric";
	ts.mysqlDataTypeStruct["float"]="cf_sql_real";
	ts.mysqlDataTypeStruct["datetime"]="cf_sql_timestamp";
	ts.mysqlDataTypeStruct["timestamp"]="cf_sql_timestamp";
	ts.mysqlDataTypeStruct["varbinary"]="cf_sql_varbinary";
	ts.mysqlDataTypeStruct["varchar"]="cf_sql_varchar";
	ts.mysqlDataTypeStruct["tinytext"]="cf_sql_varchar";
	ts.mysqlDataTypeStruct["enum"]="cf_sql_varchar";
	ts.mysqlDataTypeStruct["set"]="cf_sql_varchar";


	ts.memoryTableStruct={
		"city_distance_memory":true,
		"city_memory":true,
		"listing_memory":true
	};
	
	ts.tableConventionExceptionStruct={
		"manual_listing":{
			"primaryKey":"manual_listing_unique_id"
		},
		"listing": {
			"primaryKey":"listing_unique_id"
		},
		"city_distance_safe_update": {
			"deleted":"city_distance_deleted",
			"updatedDatetime": "city_distance_updated_datetime",
		},
		"city_memory": {
			"primaryKey": "city_id",
			"deleted":"city_deleted",
			"updatedDatetime": "city_updated_datetime",
		},
		"city_distance_memory": {
			"primaryKey": "city_distance_id",
			"deleted":"city_distance_deleted",
			"updatedDatetime": "city_distance_updated_datetime",
		},
		"listing_memory": {
			"primaryKey": "listing_unique_id",
			"deleted":"listing_deleted",
			"updatedDatetime": "listing_updated_datetime",
		}
	};


	arrJsFiles=directoryList("#request.zos.installPath#public/javascript/jetendo/", true, 'path');
	ts.arrJsFiles=[];
	for(i=1;i LTE arraylen(arrJsFiles);i++){
	 	arrayAppend(ts.arrJsFiles, replace(arrJsFiles[i], request.zos.installPath&"public/", "/z/"));
	}

	arrListingJsFiles=directoryList("#request.zos.installPath#public/javascript/jetendo-listing/", true, 'path');
	ts.arrListingJsFiles=[];
	for(i=1;i LTE arraylen(arrListingJsFiles);i++){
	 	arrayAppend(ts.arrListingJsFiles, replace(arrListingJsFiles[i], request.zos.installPath&"public/", "/z/"));
	}

	
	
	// setup legacy url redirect routes
	ts.urlRewriteStruct={
		redirectStruct={
			"/admin"={ url="/z/admin/admin-home/index" },
			"/manager"={ url="/z/admin/admin-home/index" },
			"/admin/"={ url="/z/admin/admin-home/index" },
			"/manager/"={ url="/z/admin/admin-home/index" },
			"/member"={ url="/z/admin/admin-home/index" },
			"/member/"={ url="/z/admin/admin-home/index" },
			"/z/_com/app/walkscore"={ url="/z/misc/walkscore/index" },
			"/z/_a/video"={ url="/z/misc/embed/video" },
			"/z/_a/util/walkscore"={ url="/z/misc/walkscore/index" },
			"/z/_a/secure-message"={ url="/z/a/secure-message.php"	},
			"/z/_a/content/mortgage-calculator"={ url="/z/misc/mortgage-calculator/index" },
			"/z/_a/content/mortgage-quote"={ url="/z/misc/mortgage-quote/index" },
			"/z/_a/content/agents"={ url="/z/misc/members/index" },
			"/z/_a/search-site"={ url="/z/misc/search-site/index" },
			"/z/_a/site-map"={ url="/z/misc/site-map/index" },
			"/z/_a/inquiry"={ url="/z/misc/inquiry/index" },
			"/z/_e/privacy"={ url="/z/user/privacy/index" },
			"/z/_e/in"={ url="/z/user/in/index" },
			"/z/_e/out"={ url="/z/user/out/index" },
			"/z/_e/pref"={ url="/z/user/preference/index" },
			"/z/_e/login-form"={ url="/z/user/login/index" },
			"/z/_com/listing/search"={ url="/z/listing/search/index" },
			"/z/_a/content/slideshow"={ url="/z/misc/slideshow/index" },
			"/z/_a/content/slideshow_embed"={ url="/z/misc/slideshow/embed" },
			"/z/_a/listing/cma-inquiry"={ url="/z/listing/cma-inquiry/index"},  
		}
		
	};
	
	
	t9=structnew();
	t9[request.zos.urlRoutingParameter]=true;
	t9.__zcoreinternalroutingpath=true;
	t9.zld=true;
	t9.zp=true;
	t9.zLogin=true;
	t9.fieldnames=true;
	t9.zLogOut=true;
	t9.zReset=true;
	t9.zOS_modeVarDumpName=true;
	t9.zOS_mode=true;
	t9.zOS_modeValue=true;
	t9.zDebugOn=true;
	t9.FIELDNAMES=true;
	t9.zUserSubmit=true;
	t9.zUsername=true;
	t9.zPassword=true;
	ts.repostVarsIgnoreStruct=t9;
	
	t9=structnew();
	t9.disableContentMeta=false;
	t9.arrContentReplaceKeywords=arraynew(1);
	t9.searchincludebars=false;
	t9.disableChildContentSummary=false;
	t9.hideContentSold=false;
	t9.disableChildContent=false;
	t9.contentForceOutput=false;
	t9.contentDisableLinks=false;
	t9.contentSimpleFormat=false;
	t9.tablestyle="";
	t9.content_id="";
	t9.showmlsnumber=false;
	
	t9.contentEmailFormat=false;
	ts.contentDefaultConfigStruct=t9;
	// server globals
	ts.serverGlobals=structnew(); 
	


	// list came from: https://github.com/piwik/referrer-spam-blacklist/blob/master/spammers.txt
	ts.referrerList="100dollars-seo.com,12masterov.com,4webmasters.org,7makemoneyonline.com,acads.net,adcash.com,adviceforum.info,affordablewebsitesandmobileapps.com,akuhni.by,allwomen.info,alpharma.net,altermix.ua,amt-k.ru,anal-acrobats.hol.es,android-style.com,anticrawler.org,arkkivoltti.net,aruplighting.com,baladur.ru,bard-real.com.ua,best-seo-offer.com,best-seo-solution.com,bestmobilityscooterstoday.com,bestwebsitesawards.com,billiard-classic.com.ua,blackhatworth.com,blue-square.biz,bmw.afora.ru,brakehawk.com,brothers-smaller.ru,buttons-for-website.com,buttons-for-your-website.com,buy-cheap-online.info,buy-forum.ru,cardiosport.com.ua,cartechnic.ru,cenokos.ru,cenoval.ru,ci.ua,cityadspix.com,cubook.supernew.org,customsua.com.ua,dailyrank.net,darodar.com,delfin-aqua.com.ua,detskie-konstruktory.ru,dipstar.org,djekxa.ru,dojki-hd.com,domination.ml,doska-vsem.ru,dostavka-v-krym.com,drupa.com,dvr.biz.ua,e-kwiaciarz.pl,ecomp3.ru,econom.co,edakgfvwql.ru,elmifarhangi.com,este-line.com.ua,euromasterclass.ru,europages.com.ru,eurosamodelki.ru,event-tracking.com,forum20.smailik.org,forum69.info,free-share-buttons.com,free-social-buttons.com,freewhatsappload.com,generalporn.org,germes-trans.com,get-free-traffic-now.com,ghazel.ru,girlporn.ru,gkvector.ru,gobongo.info,goodprotein.ru,googlsucks.com,guardlink.org,hulfingtonpost.com,humanorightswatch.org,hundejo.com,hvd-store.com,ico.re,igru-xbox.net,iloveitaly.ro,iloveitaly.ru,ilovevitaly.co,ilovevitaly.com,ilovevitaly.info,ilovevitaly.org,ilovevitaly.ru,iminent.com,imperiafilm.ru,iskalko.ru,ispaniya-costa-blanca.ru,it-max.com.ua,jjbabskoe.ru,kabbalah-red-bracelets.com,kambasoft.com,kazrent.com,kino-fun.ru,kino-key.info,kinopolet.net,laxdrills.com,littleberry.ru,luxup.ru,makemoneyonline.com,maridan.com.ua,masterseek.com,mebelcomplekt.ru,mebeldekor.com.ua,med-zdorovie.com.ua,minegam.com,mirobuvi.com.ua,msk.afora.ru,myftpupload.com,niki-mlt.ru,novosti-hi-tech.ru,o-o-6-o-o.com,o-o-8-o-o.ru,ok.ru,onlywoman.org,ooo-olni.ru,ozas.net,palvira.com.ua,photokitchendesign.com,pornhub-forum.ga,pornhub-forum.uni.me,pornhub-ru.com,pornoforadult.com,pozdravleniya-c.ru,priceg.com,prodvigator.ua,psa48.ru,qitt.ru,ranksonic.info,ranksonic.org,rapidgator-porn.ga,research.ifmo.ru,resellerclub.com,sady-urala.ru,sanjosestartups.com,savetubevideo.com,screentoolkit.com,search-error.com,semalt.com,semaltmedia.com,seo-smm.kz,seoexperimenty.ru,sexyteens.hol.es,shop.xz618.com,simple-share-buttons.com,slftsdybbg.ru,slkrm.ru,social-buttons.com,socialseet.ru,sohoindia.net,spb.afora.ru,spravka130.ru,superiends.org,tattooha.com,tedxrj.com,theguardlan.com,toyota.7zap.com,trafficmonetize.org,trion.od.ua,vodkoved.ru,webmaster-traffic.com,webmonetizer.net,websites-reviews.com,websocial.me,ykecwqlixx.ru,youporn-forum.ga,youporn-forum.uni.me,zastroyka.org,грузоподъемные-машины.рф,наркомания.лечениенаркомании.com,непереводимая.рф,снятьдомвсевастополе.рф";
	listCount=listLen(ts.referrerList, ",");
	arrList=[];
	for(i=1;i LTE listCount;i++){
		arrayAppend(arrList, '');
	}
	ts.referrerlistReplace=arrayToList(arrList, ",");

	t3=structnew();
	t3["/z/misc/system/ext"]="";
	t3["/z/listing/inquiry/index"]="";
	t3["/z/listing/inquiry-pop/index"]="";
	ts.spiderTrapScripts=t3;
	ts.spiderList="social_buttons,simple_share_buttons,bot,spider,scrape,purebot,mrsputnik,jikespider,voilabot,yandexbot,lycosa.se,facebookfeedparser,sogou_web_spider,ezooms,mj12bot,bingbot,sistrix_crawler,abachobot,abcdatos_botlink_,accoona_ai_agent,ace_explorer,acoon,aesop_com_spiderman,ah_ha_com_crawler,aipbot,aitcsrobot_,alkalinebot,almaden,answerbus_,anthillv_,aolserver_tcl,appie,arachnoidea,arachnophilia,araneo_,araybot_,architextspider,arks_,aspider_,atlocalbot,atn_worldwide,atomz,auditbot,auresys_,autolinkspro_link_checker_,awapclient,backrub_,baiduspider_,bayspider,bbot_,bigcliquebot,big_brother,bjaaland_,blackberry,blackwidow,blogslive_,blogssay_blog_search_crawler_,boitho_com_dc,borg_bot_,botswana_v_,boxseabot_,bravobrian_bstop_bravobrian_it,bruinbot_,bspider_libwww_perl_,bumblebee_relevare_com,buscaplus_robi,butch_,cactvs_chemistry_spider,calif_,cehmgnkabgxpet_tksgsybnlkj_h_qeteeyp,cfetch,checkbot_x_xx_lwp_x,cienciaficcion_net_spider,cipinetbot,cjnetworkquality_,clever_components_downloader,cmc_,combine,computingsite_robi_,confuzzledbot_x_x,contactbot,converacrawler,converamultimediacrawler,coolbot,cosmixcrawler,cosmos_,crawlconvera_,crawlpaper_n_n_n,curl,cusco_,cyberspyder_,cydralspider,cydralspider_x_x,cyveillance,datacha_s,deepak_usc,deepindex,desertrealm_com_j_,deweb_,diamond,diamondbot,dienstspider_,die_blinde_kuh,digger_jdk_,digimarc_cgireader_,digimarc_webreader_,diibot,dlw_robot_x_y,dnabot_,dnsyu_gedsariwq_nwdfrpmu_gscpoywyn_,dpeoorctnm_ryvitlkrr,dragonbot_libwww_,dtsearch,dumbot,duppies,dwcp_,ebiness_a,eit_link_verifier_robot_,elfinbot,emacs_w_v_,emailsiphon,emc_spider,emeraldshield_com_webbot,esculapio_,esirover_v_,esismartspider,esther,evliya_celebi,experibot,expired_domain_sleuth,explorersearch,extreme_picture_finder,ezresult,fastcrawler_x,fast_crawler_v_x,fast_enterprise_crawler_used_by_fast_,fast_partnersite_crawler,fast_webcrawler,fdm_x,feedfetcher_google_,feedfinder,feedster_crawler,feedvalidator,felixide_,fetch_libfetch,fido,fido_harvest_pl_,findexa_crawler_,findimbot,findlinks,fish_search_robot,fluffy_the_spider,freecrawl,funnelweb_,gaisbot,gammaspider_xxxxxxx_,gazz_,gcreep_,geniebot_,geniebot_wgao_genieknows_com,gestalticonoclast_libwww_fm_,gethtmlcontents_,geturl_rexx_v_,gigabot,gigabotsitesearch,girafa_com,golem_,googlebot,googlebot_image,googlebot_x,grabber,griffon_,gromit_,grub_crawler,gulliver,gulper,gulper_web_bot_,harvest,havindex_x_xx_bxx_,henrythemiragorobot,hl_ftien_spider,holmes,hometown_spider_pro,htdig_b_,htmlgobble_v_,http_www_sygol_com,hämähäkki_,iajabot_,ia_archiver,ichiro,iltrovatore_setaccio,imac_,image_kapsi_net_,incywincy_b_,indy_library,ineturl,informant,infoseek_robot_,infoseek_sidewinder,infospiders_,ingrid_,innerprisebot,inspectorwww_,internet_cruiser_robot_,ip_works_v_http,irlbot,israelisearch_,i_robot_,jakarta_commons_httpclient,javabee,jayde_crawler_http_,jbot,jcrawler_,jetbot,jobo,jobot_alpha_libwww_perl_,jubiirobot_version_,jumpstation,katipo_,kdd_explorer_,kit_fireball_,ko_yappo_robot_,labelgrab_,larbin,libwww_perl,linkidator_,linkscan_server_linkscan_workstation_,linksmanager_com_,linkwalker,lmqueuebot,lnspiderguy,localcombot,lockon_xxxxx,logo_gif_crawler,lotus_notes,lwp,lycos_spider_,lycos_spider_t_rex_,lycos_x_x,magpie_,mantraagent,markwatch,marvin_infoseek,mediafox_x_y,mediapartners_google,merzscope,metaspinner,metatagrobot,mfc_tear_sample,microsoft_data_access_internet_publishing_provider_cache_manager,microsoft_data_access_internet_publishing_provider_dav_,microsoft_data_access_internet_publishing_provider_protocol_discovery,microsoft_url_control__,microsoft_webdav_miniredir,mindcrawler,minirank,missigua_locator_,mister_pix_ii_,mj_bot,mnogosearch,moget_,momspider_libwww_perl_,monster_vx_x_x_type,motor_,mouse_house_,mozdex,msfrontpage,mshelp,msnbot,msnbot_,msnptc,msproxy,muninn_libwww_perl_,muscatferret_,mwdsearch_,nameprotect,nationaldirectory_superspider,naverbot_,nazilla,ndspider_,nec_meshexplorer,nederland_zoek,netcarta_cyberpilot_pro,netmechanic,netmechanic_v_,netscoop_libwww_a,newscan_online_,nhsewalker_,nicebot,nomad_v_x,northstar,npbot,nutch,nutchcvs,objectssearch,occam_,ocelli,ocp_hrs_,omnifind_sanantonio_,ontospider_libwww_perl_,openbot,orbsearch_,os_heritrix,packrat_,pageboy_,parasite_,patric_a,peregrinator_mathematics_,perlcrawler_xavatoria_,pgp_ka_,phpdig_x_x_x,piltdownman_profitnet_myezmail_com,ping_blo_gs,pioneer,pipeliner,plumtreewebaccessor_,pmafind,poirot,pompos,poppi_,portalbspider_,portaljuice_com_,program_shareware_,psbot,psbot_x,puresight,python_urllib,p_p_validator,raven_v_,reciprocal_links_checker_,redcarpet,resume_robot,rhcs_a,riroikrcjrx_grefrxtwo,rixbot,road_runner_imagescape_robot,robbie_,robocrawl,robofox_v_,robot_du_crim_a,robozilla,robozilla_,roffle,root_,rora_ibm_test_crawler_rhlas_,roverbot,rpt_httpclient,rufusbot_,rules_libwww_,sbider,schmozilla,scooter,scooter_g_r_a_b_v_,scrubby,scspider,searchprocess_,seekbot,semanticdiscovery,senrigan_xxxxxx,sensis_web_crawler_,sg_scout,shagseeker_at_http_www_shagseek_com_,shai_hulud,sherlock,shopwiki,simbot_,sitetech_rover,site_valet,slcrawler,slurp,snap_com_beta_crawler_v_,snooper_b_,solbot_lwp_,speedy_spider,spiderbot_,spiderline_,spiderman_,ssearcher_,straight_flash_getterroboplus_,suntek_,surf,surveybot,tamu_cs_irl_crawler,tarantula,tarka,tarspider,techbot,templeton_version_for_platform_,teoma_agent_,teradex_mapper,titan_,titin_,tlspider_,tracerlock,travelbot,travellazerbot,turnitinbot,turnpike_emporium_linkchecker,tutorgigbot,tutorial_crawler_,twiceler_www_cuill_com,ucsd_crawler,udmsearch,uk_searcher_spider,ultraseek,unchaos_crawler_,uoftdb_experiment_,uptimebot,urcpbfyyfh_qxsaxtoscm,urlck_,url_spider_pro,valkyrie_libwww_perl_,versus_,verticrawl,victoria_,vision_search_,void_bot_,voyager,voyager_,vwbot_k_,waol_exe,wdg_validator,webbandit_,webcatcher_,webcollage,webcollage_perl,webcopy_,webcrawler,webindexer,weblayers_,weblinker_libwww_perl_,webmoose__,webquest_,webreaper_webreaper_otway_com_,webs_recruit_co_jp,webtrends,webvac_,webwalk,webwalker_,webwatch,web_robot,web_robot_pegasus,wget,wget_,whatuseek_winona_,winona,wintools,wired_digital_newsbot_,wlm_,wolp_mda_,wotbox,wume_crawler,wwwc_,wwwwanderer_v_,www_mechanize,w_crobot,w_c_validator,w_index,w_mir,w_m_x_xxx,w_pspider_xxx_by_wap_com,xenu_link_sleuth,xget_,yacy_,yahoofeedseeker,yahoofeedseeker_testing,yahooseeker,yahoo_blogs,yahoo_mmcrawler,yahoo_verticalcrawler_formerwebcrawler,ydr_ecjghfxwuxxljqauwpgcgwdkmwnwn,y_oasis,zao_crawler,zealbot,zeus,zeusbot,zipppbot,zyborg,_ahoy_the_homepage_finder_,_hazel_s_ferret_web_hopper_,_hku_www_robot_,_iagent_,_ibm_planetwide_,_joebot_x_x_,_openfind_data_gatherer_openbot_,_openfind_piranha_shark_,_safetynet_robot_,_webfetcher_";
	ts.spiderListReplace="_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_";

	t3=structnew();
	t3["/z/misc/system/ext"]=true;
	t3["/z/listing/sl/index"]=true;
	t3["/z/misc/slideshow/index"]=true;
	t3["/z/_com/app/walkscore"]=true;
	t3["/z/user/login/index"]=true;
	t3["/z/listing/ajax-geocoder/index"]=true;
	t3["/z/listing/search-form-js/index"]=true;
	t3["/z/listing/inquiry-pop/index"]=true;
	ts.trackingDisabledStruct=t3;
	
	
	// for statistics
	ts.requestCacheIndex=0;	
	ts.arrRequestCache=arraynew(1);
	ts.runningScriptIndex=0;
	ts.runningScriptStruct=structnew();
	ts.resetApplicationTrackerStruct=structnew();


	ts.disabledHTMLTagList=getDisabledHTMLTagList();
	</cfscript>
</cffunction>


<cffunction name="getDisabledHTMLTagList" localmode="modern" access="private">
	<cfscript>
		allTags={
'!DOCTYPE':true,
'a':true,
'abbr':true,
'acronym':true,
'address':true,
'applet':true,
'area':true,
'article':true,
'aside':true,
'audio':true,
'b':true,
'base':true,
'basefont':true,
'bdi':true,
'bdo':true,
'big':true,
'blockquote':true,
'body':true,
'br':true,
'button':true,
'canvas':true,
'caption':true,
'center':true,
'cite':true,
'code':true,
'col':true,
'colgroup':true,
'data':true,
'datalist':true,
'dd':true,
'del':true,
'details':true,
'dfn':true,
'dialog':true,
'dir':true,
'div':true,
'dl':true,
'dt':true,
'em':true,
'embed':true,
'fieldset':true,
'figcaption':true,
'figure':true,
'font':true,
'footer':true,
'form':true,
'frame':true,
'frameset':true,
'h1 - h6':true,
'head':true,
'header':true,
'hr':true,
'html':true,
'i':true,
'iframe':true,
'img':true,
'input':true,
'ins':true,
'kbd':true,
'keygen':true,
'label':true,
'legend':true,
'li':true,
'link':true,
'main':true,
'map':true,
'mark':true,
'menu':true,
'menuitem':true,
'meta':true,
'meter':true,
'nav':true,
'noframes':true,
'noscript':true,
'object':true,
'ol':true,
'optgroup':true,
'option':true,
'output':true,
'p':true,
'param':true,
'picture':true,
'pre':true,
'progress':true,
'q':true,
'rp':true,
'rt':true,
'ruby':true,
's':true,
'samp':true,
'script':true,
'section':true,
'select':true,
'small':true,
'source':true,
'span':true,
'strike':true,
'strong':true,
'style':true,
'sub':true,
'summary':true,
'sup':true,
'table':true,
'tbody':true,
'td':true,
'textarea':true,
'tfoot':true,
'th':true,
'thead':true,
'time':true,
'title':true,
'tr':true,
'track':true,
'tt':true,
'u':true,
'ul':true,
'var':true,
'video':true,
'wbr':true
};

	var whitelistTags = [
		'a',
		'area',
		'map',
		'abbr',
		'b',
		'blockquote',
		'br',
		'cite',
		'code',
		'dl',
		'dd',
		'div',
		'dt',
		'em',
		'h1',
		'h2',
		'h3',
		'h4',
		'h5',
		'h6',
		'hr',
		'i',
		'img',
		'li',
		'ol',
		'p',
		'pre',
		's',
		'span',
		'small',
		'strong',
		'sub',
		'sup',
		'table',
		'thead',
		'tbody',
		'tr',
		'th',
		'td',
		'tfoot',
		'style',
		'u',
		'ul',
		'meta',
		'link',
		'address',
		'caption',
		'footer',
		'section',
		'header',
		'html',
		'head',
		'body',
		'title',
		'strike',
		'style'
	];

	badTagStruct=duplicate(allTags);
	for ( tag in whitelistTags ) {
		structdelete(badTagStruct, tag);
	}
	return structkeylist(badTagStruct, "|");
	</cfscript>
</cffunction>

<cffunction name="loadDbCFC" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	/*if(structkeyexists(request.zos, 'queryObject')){
		return;
	}*/
	ts=arguments.ss;
	if(not structkeyexists(request.zos, 'globals')){
		request.zos.globals=structnew();
		structappend(request.zos.globals,duplicate(ts.serverGlobals));
	}
	if(request.zos.isdeveloper and isDefined('request.zsession.verifyQueries') and request.zsession.verifyQueries){
		verifyQueriesEnabled=true;
	}else{
		verifyQueriesEnabled=false;
	}
	ts.dbInitConfigStruct={
		insertIdSQL:"select last_insert_id() id",
		datasource:request.zos.globals.serverdatasource,
		parseSQLFunctionStruct:{
			checkSiteId:application.zcore.functions.zVerifySiteIdsInDBCFCQuery
			, checkDeletedField:application.zcore.functions.zVerifyDeletedInDBCFCQuery
		},
		verifyQueriesEnabled:verifyQueriesEnabled,
		cacheStructKey:'application.zcore.queryCache'
	}
	ts.db.init(ts.dbInitConfigStruct);
	request.zos.queryObject=ts.db.newQuery();

	c=ts.db.getConfig();
	c.datasource=request.zos.globals.serverdatasource;
	c.verifyQueriesEnabled=false;
	c.cacheDisabled=false;
	c.autoReset=false;
	request.zos.noVerifyQueryObject=ts.db.newQuery(c); 
	</cfscript>
</cffunction>

<cffunction name="setupAppGlobals2" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts=arguments.ss; 
    versionCom=createobject("component", "zcorerootmapping.version");
    ts2=versionCom.getVersion();
    ts.databaseVersion=ts2.databaseVersion;
    ts.sourceVersion=ts2.sourceVersion;
    ts.javascriptVersion=ts2.javascriptVersion;
    
	if(isDefined('request.zsession.user')){
		request.zos.userSession=duplicate(request.zsession.user);
	}else{
		request.zos.userSession=structnew();
		request.zos.userSession.groupAccess=structnew();	
	}
	ts.uuidCacheStruct=structnew();
	ts.imageLibraryLastDeleteDate="";
	ts.compiledTemplatePathCache=structnew();
	ts.forceUserUpdateSession={};
	
	ts.appComPathStruct=structnew();
	// 9 is a placeholder for documentation search.  It is not a full featured plugin yet.
	//ts.appComPathStruct[9]={name:"help", cfcPath:"zcorerootmapping.mvc.z.admin.controller.help", cache:true};
	ts.appComPathStruct[10]={name:"blog", cfcPath:"zcorerootmapping.mvc.z.blog.controller.blog", cache:true};
	ts.appComPathStruct[11]={name:"listing", cfcPath:"zcorerootmapping.mvc.z.listing.controller.listing", cache:false};
	ts.appComPathStruct[12]={name:"content", cfcPath:"zcorerootmapping.mvc.z.content.controller.content", cache:true};
	ts.appComPathStruct[13]={name:"rental", cfcPath:"zcorerootmapping.mvc.z.rental.controller.rental", cache:false};
	ts.appComPathStruct[15]={name:"ecommerce", cfcPath:"zcorerootmapping.mvc.z.ecommerce.controller.ecommerce", cache:true};
	ts.appComPathStruct[16]={name:"reservation", cfcPath:"zcorerootmapping.mvc.z.reservation.controller.reservation", cache:true};
	ts.appComPathStruct[17]={name:"event", cfcPath:"zcorerootmapping.mvc.z.event.controller.event", cache:true};
	ts.appComPathStruct[18]={name:"job", cfcPath:"zcorerootmapping.mvc.z.job.controller.job", cache:true};
	ts.appComPathStruct[19]={name:"directory", cfcPath:"zcorerootmapping.mvc.z.directory.controller.directory", cache:true};
	ts.appComPathStruct[20]={name:"section", cfcPath:"zcorerootmapping.mvc.z.section.controller.section", cache:true};
	ts.appComName={};
	for(i in ts.appComPathStruct){
		ts.appComName[ts.appComPathStruct[i].name]=i;
	}
	
	tempVar=createobject("component","zcorerootmapping.functionInclude");
	ts.functions=tempVar.init();
	if(request.zos.allowRequestCFC){
		request.zos.functions=ts.functions;
	}
	application.zcore.functions=ts.functions; 
	ts.serverGlobals.serverhomedir=request.zos.zcoreRootPath;
	ts.serverGlobals.serverdatasource=request.zos.zcoreDatasource;
	ts.serverGlobals.datasource=request.zos.zcoreDatasource;



	
	query name="qA" datasource="#ts.serverGlobals.serverdatasource#"{
		writeoutput("SHOW DATABASES like '%#request.zos.zcoredatasource#%' ");
	}
	if(qA.recordcount EQ 0){
		throw("zcorerootmapping ERROR: The database and datasource name must be identical. #ts.serverGlobals.datasource# does not exist in database server. Please correct site globals.");
	} 
	
	// default environment variables
	// es=structnew();
	// es.live=true;
	// es.databaseprefix="";
	// es.shortdomain="";
	// es.datasource="#request.zos.zcoreDatasource#";
	
	// default global variables
	// ds=structnew();
	// ds.id="";
	// ds.emailCampaignFrom=request.zos.developerEmailFrom;
	// ds.emailpopserver="mailserver";
	// ds.emailusername=request.zos.developerEmailTo;
	// ds.emailpassword="notusedyet";
	// ds.emailCampaignFrom="";
	// ds.emailCampaignFrom="";
	// ds.emailCampaignFrom="";
	// ds.editorStylesheet="/stylesheets/style-manager.css";
	// ds.editorFonts="";
	// ds.typekitURL="";
	// ds.maximagewidth="760";
	// ds.domainMapping=structnew();
	// ds.environment=structnew();
	// ds.environment.dev=duplicate(es);
	// ds.environment.test=duplicate(es);
	// ds.environment.live=duplicate(es);
	
	// zTempGlobalStruct=StructNew();
	// zTempCurrentPath="";
	/*ts.abusiveIPStruct=structnew();
	for(i=0;i LTE 59;i++){
		ts.abusiveIPStruct[i]=structnew();
	}
	ts.abusiveIPDate=0;
	if(isDefined('application.zcore.abusiveBlockedIpStruct') and structkeyexists(form,  'force') EQ false){
		ts.abusiveBlockedIpStruct=application.zcore.abusiveBlockedIpStruct;
	}else{
		query name="qS" datasource="#request.zos.zcoreDatasource#"{
			writeoutput('SELECT ip_block_ip FROM ip_block WHERE ip_block_deleted=0 ');
		}
		ts.abusiveBlockedIpStruct=structnew();
		for(i=1;i LTE qs.recordcount;i++){
		ts.abusiveBlockedIpStruct[qs.ip_block_ip[i]]=true;	
		}
	}*/
	ts.processList=structnew(); 
	ts.serverglobals.serveremail = request.zos.developerEmailTo;
	ts.serverglobals.serverpass = ""; 
	if(request.zos.cgi.http_host CONTAINS "."&request.zos.testDomain){
		ts.serverglobals.serverdomain = request.zOS.zcoreTestAdminDomain;
		ts.serverglobals.serversecuredomain = request.zOS.zcoreTestAdminDomain;
		ts.serverglobals.servershortdomain = replace(replace(request.zOS.zcoreTestAdminDomain,"http://",""),"https://","");
	}else{
		ts.serverglobals.serverdomain = request.zOS.zcoreAdminDomain;
		ts.serverglobals.serversecuredomain = request.zOS.zcoreAdminDomain;
		ts.serverglobals.servershortdomain = replace(replace(request.zOS.zcoreAdminDomain,"http://",""),"https://","");
	}
	ts.serverglobals.serverdatasource="#request.zos.zcoreDatasource#";
	ts.serverglobals.serverid = 1;
	ts.serverglobals.serversiteroot = ""; 
	ts.serverglobals.servername = ts.serverglobals.servershortdomain;
	ts.serverglobals.serverprivatehomedir = request.zos.zcoreRootPrivatePath;
	ts.serverglobals.serverhomedir = request.zos.zcoreRootPath;
	ts.serverglobals.serverdebugenabled = true;
	ts.serverglobals.serveremailpopserver = "mailserver";
	ts.serverglobals.serveremailpassword = "password";
	ts.serverglobals.serveremailusername = "username";
	request.zos.requestLogEntry('Application.cfc onApplicationStart 3-1-2');
	ts.cloudVendorLookup={
		"1":"zcorerootmapping.com.cloud.local",
		"2":"zcorerootmapping.com.cloud.rackspace",
		//"3":"zcorerootmapping.com.cloud.google",
		//"4":"zcorerootmapping.com.cloud.microsoft",
		//"5":"zcorerootmapping.com.cloud.amazon"
	}; 
	 
	if(not fileexists(ts.serverglobals.serverprivatehomedir&"_cache/scripts/sites.json")){ 
		application[request.zos.installPath&":displaySetupScreen"]=true;
		dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
		if(not dbUpgradeCom.checkVersion()){
			if(request.zos.isTestServer or request.zos.isDeveloper){
				echo('Database upgrade failed');
				abort;
			}
		}
	}

	
	// ts.themeTypeData={};
	// ts.widgetTypeData={}
	
	var qDomain=0;
	query name="qDomain" datasource="#ts.serverGlobals.serverdatasource#"{
		writeoutput("SELECT domain_redirect.*, site.site_domain 
		FROM domain_redirect, site 
		WHERE site.site_id = domain_redirect.site_id and 
		site.site_id <> -1");
	}
	ts.domainRedirectStruct={};
	for(var row in qDomain){
		if(structkeyexists(row, 'site_deleted') and row.site_deleted EQ 0){
			continue;
		}
		if(structkeyexists(row, 'domain_redirect_deleted') and row.domain_redirect_deleted EQ 0){
			continue;
		}
		ts.domainRedirectStruct[row.domain_redirect_old_domain]=row;
	}
	if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'siteglobals')){
		ts.siteglobals=application.zcore.siteglobals;
	}else{
		ts.siteglobals={};
	}
	/*query name="qS" datasource="#request.zos.zcoreDatasource#"{
		writeoutput("SELECT site_id, site_short_domain FROM `site` 
		WHERE site_active='1' ");
	} 
	for(row in qS){
		if(structkeyexists(row, 'site_deleted') and row.site_deleted EQ 0){
			continue;
		}
		tempPath=application.zcore.functions.zGetDomainInstallPath(row.site_short_domain);
		tempPath2=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
		if(not structkeyexists(ts.siteglobals, row.site_id) and fileexists(tempPath2&"_cache/scripts/global.json")){
			tempGlobal=deserializeJson(application.zcore.functions.zreadfile(tempPath2&"_cache/scripts/global.json"));
			structappend(tempGlobal, ts.serverGlobals, false);
			tempGlobal.homeDir=tempPath;
			tempGlobal.secureHomeDir=tempPath;
			tempGlobal.privateHomeDir=tempPath2; 
			ts.siteglobals[row.site_id]=tempGlobal;
		}
	} */
	
	request.zos.requestLogEntry('Application.cfc onApplicationStart 3-1');
	ts.componentObjectCache=structnew();
	ts.componentObjectCache.cloudFile=CreateObject("component","zcorerootmapping.com.zos.cloudFile");
	ts.componentObjectCache.context=CreateObject("component","zcorerootmapping.com.zos.context");
	ts.componentObjectCache.cache=CreateObject("component","zcorerootmapping.com.zos.cache");
	ts.componentObjectCache.session=CreateObject("component","zcorerootmapping.com.zos.session");
	ts.componentObjectCache.tracking=CreateObject("component","zcorerootmapping.com.app.tracking");
	ts.componentObjectCache.template=CreateObject("component","zcorerootmapping.com.zos.template");
	ts.componentObjectCache.routing=CreateObject("component", "zcorerootmapping.com.zos.routing");
	ts.componentObjectCache.debugger=CreateObject("component","zcorerootmapping.com.zos.debugger");
	ts.componentObjectCache.user=CreateObject("component","zcorerootmapping.com.user.user");
	ts.componentObjectCache.skin=CreateObject("component","zcorerootmapping.com.display.skin");
	ts.componentObjectCache.status=CreateObject("component","zcorerootmapping.com.zos.status");
	ts.componentObjectCache.email=CreateObject("component","zcorerootmapping.com.app.email");
	ts.componentObjectCache.siteOptionCom=CreateObject("component","zcorerootmapping.com.app.site-option");
	ts.componentObjectCache.imageLibraryCom=CreateObject("component","zcorerootmapping.com.app.image-library");
	ts.componentObjectCache.hook=CreateObject("component","zcorerootmapping.com.zos.hook");
	ts.componentObjectCache.app=CreateObject("component","zcorerootmapping.com.zos.app");
	ts.componentObjectCache.db=createobject("component","zcorerootmapping.com.model.db"); 
	ts.componentObjectCache.paypal=createobject("component","zcorerootmapping.com.ecommerce.paypal");
	ts.componentObjectCache.adminSecurityFilter=createobject("component","zcorerootmapping.com.app.adminSecurityFilter");
	ts.componentObjectCache.grid=createobject("component","zcorerootmapping.com.grid.grid");
	ts.componentObjectCache.virtualFile=createobject("component","zcorerootmapping.com.zos.virtualFile");
	ts.componentObjectCache.featureCom=CreateObject("component","zcorerootmapping.mvc.z.feature.feature");

	ts.componentObjectCache.siteOptionCom.init("site", "site");
 	ts.cloudVendor=ts.componentObjectCache.cloudFile.getCloudVendors();

	ts.featureData={};
	ts.featureData.fieldTypeStruct=ts.componentObjectCache.featureCom.getFieldTypes();
	ts.featureData.arrCustomDelete=ts.componentObjectCache.featureCom.getTypeCustomDeleteArray(ts.featureData);

	ts.soGroupData={
		optionTypeStruct:ts.componentObjectCache.siteOptionCom.getOptionTypes()
	};
	ts.soGroupData.arrCustomDelete=ts.componentObjectCache.siteOptionCom.getTypeCustomDeleteArray(ts.soGroupData);
	ts.themeTypeData={
		optionTypeStruct:{}
	};
	ts.widgetTypeData={
		optionTypeStruct:{}
	};


	
	structappend(ts, ts.componentObjectCache);
	if(request.zos.allowRequestCFC){
		structappend(request.zos, ts.componentObjectCache, true);
	}
	application.zcore.db=ts.db;
	
	request.zos.requestLogEntry('Application.cfc onApplicationStart 3-2');
	ts.cacheData={
		tagHashCache:structnew()
	}
	/*
	// this need to be within request.zos.installPath now.
	directory action="list" recurse="yes" directory="/var/jetendo-server/nginx/tagcache/" name="qD";
	for(row IN qD){
		ts.cacheData.tagHashCache[left(row.name, len(row.name)-5)]=true;
	}
	*/

	loadDbCFC(ts);
	// if(request.zos.isTestServer){
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.rebuildFeaturesCache(ts, true); 
	// }
	/*
	request.zos.globals=structnew();
	structappend(request.zos.globals,duplicate(ts.serverGlobals));
	if(request.zos.isdeveloper and isDefined('request.zsession.verifyQueries') and request.zsession.verifyQueries){
		verifyQueriesEnabled=true;
	}else{
		verifyQueriesEnabled=false;
	}
	ts.dbInitConfigStruct={
		insertIdSQL:"select last_insert_id() id",
		datasource:request.zos.globals.serverdatasource,
		parseSQLFunctionStruct:{
			checkSiteId:application.zcore.functions.zVerifySiteIdsInDBCFCQuery
			, checkDeletedField:application.zcore.functions.zVerifyDeletedInDBCFCQuery
		},
		verifyQueriesEnabled:verifyQueriesEnabled,
		cacheStructKey:'application.zcore.queryCache'
	}
	ts.db.init(ts.dbInitConfigStruct);
	request.zos.queryObject=ts.db.newQuery();
	
	
	c=ts.db.getConfig();
	c.datasource=request.zos.globals.serverdatasource;
	c.verifyQueriesEnabled=false;
	c.cacheDisabled=false;
	c.autoReset=false;
	request.zos.noVerifyQueryObject=ts.db.newQuery(c);*/

	db=request.zos.queryObject;
	db.sql="SHOW VARIABLES LIKE #db.param('version')#";
	
	qV=db.execute("qV");
	ts.enableFullTextIndex=false;
	if(qV.recordcount NEQ 0){
		arrV=listtoarray(qV.value, ".", false);
		if(arrV[1] GTE 10){
			ts.enableFullTextIndex=true;
		}
	}
	

	db.sql="SELECT * FROM #db.table("state", request.zos.zcoreDatasource)# 
	order by state_state asc";
	qState=db.execute("qState");
	ts.stateStruct={};
	ts.arrState=[];
	for(row in qState){
		ts.stateStruct[row.state_code]=row.state_state;
		arrayAppend(ts.arrState, row);
	}
	db.sql="SELECT * FROM #db.table("country", request.zos.zcoreDatasource)# 
	ORDER BY country_name ASC";
	qCountry=db.execute("qCountry");
	ts.countryStruct={};
	ts.arrCountry=[];
	for(row in qCountry){
		ts.countryStruct[row.country_code]=row.country_name;
		arrayAppend(ts.arrCountry, row);
	}

	ts.verifyTablesExcludeStruct={};
	ts.verifyTablesExcludeStruct[request.zos.zcoreDatasource]={ 
	};
	
	ts.primaryKeyMapStruct={};
	//ts.primaryKeyMapStruct[request.zos.zcoreDatasource&".special_rate"]="rate_id";
	
	ts.helpStruct=structnew();
	datasourceUniqueStruct=structnew();
	datasourceUniqueStruct[request.zos.zcoredatasource]=true;
	ts.arrGlobalDatasources=structkeyarray(datasourceUniqueStruct);
	ts.tableColumns=structnew();
	ts.tablesWithSiteIdStruct=structnew();


	request.zos.requestLogEntry('Application.cfc onApplicationStart 3-3');


	application.zcore.functions.zUpdateTableColumnCache(ts);

	application.zcore.arrGlobalDatasources=ts.arrGlobalDatasources;
	application.zcore.verifyTablesExcludeStruct=ts.verifyTablesExcludeStruct;
	application.zcore.primaryKeyMapStruct=ts.primaryKeyMapStruct;
	application.zcore.tableColumns=ts.tableColumns;
	// doesn't appear to be in use and breaks new startup process
	//application.zcore.siteTableColumns=ts.siteTableColumns;
	application.zcore.tablesWithSiteIdStruct=ts.tablesWithSiteIdStruct;
	if(structkeyexists(application, request.zos.installPath&":dbUpgradeCheckVersion")){
		// verify tables
		verifyTablesCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.verify-tables");
		arrLog=verifyTablesCom.index(true);
		structdelete(application, request.zos.installPath&":dbUpgradeCheckVersion");
	}
	query name="qVersion" datasource="#request.zos.zcoreDatasource#"{
		echo("SELECT * FROM jetendo_setup LIMIT 0,1");
	}
	if(qVersion.recordcount NEQ 0){
		ts.installedDatabaseVersion=qVersion.jetendo_setup_database_version;
	}else{
		ts.installedDatabaseVersion=0;
	}
   
	dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
	if(not dbUpgradeCom.checkVersion()){
		if(request.zos.isTestServer or request.zos.isDeveloper){
			echo('Database upgrade failed');
			abort;
		}
	}


	request.zos.requestLogEntry('Application.cfc onApplicationStart 3-4');
	
	ts.controllerComponentCache=structnew();
	ts.registeredControllerStruct=structnew();
	ts.registeredControllerPathStruct=structnew();
	ts.hookAppCom=structnew();
	request.zos.functions.zUpdateGlobalMVCData(ts, false);
	if(fileexists(request.zos.installPath&"database-upgrade/tooltips.json")){
		ts.helpStruct=deserializeJson(application.zcore.functions.zreadfile(request.zos.installPath&"database-upgrade/tooltips.json"));
	}
	if(request.zos.cfmlServerKey EQ "railo"){
		ts.cfmlwebinfpath=expandpath("/railo-context/");
	}else{
		ts.cfmlwebinfpath=expandpath("/lucee-context/");
	}
	ts.cfmlwebinfpath=listdeleteat(ts.cfmlwebinfpath, listlen(ts.cfmlwebinfpath,"/"),"/")&"/";
	ts.searchformresetdate=now();
	ts.templateCache=structnew();
	ts.searchFormCache=structnew();
	 
	ts.skin.onApplicationStart(ts);
	application.zcore=ts;
	</cfscript>
</cffunction>


<cffunction name="OnApplicationListingStart" localmode="modern" access="public"  returntype="any" output="false" hint="Fires when the application is first created.">
	<cfscript>
	loadDbCFC(application.zcore); 

	request.zos.requestLogEntry('Application.cfc OnApplicationListingStart begin');
	if(request.zos.zreset EQ "app" and structkeyexists(application, 'zcore') and structkeyexists(form, 'zforcelisting') EQ false and structkeyexists(application.zcore,'listing') and structkeyexists(application.zcore,'listingStruct')){ 
		if(request.zos.allowRequestCFC){
			request.zos["listingCom"]=application.zcore.listingCom;
		}
	}else{
		application.zcore.listingCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.listing");
		ts=structnew();
		if(request.zos.allowRequestCFC){
			request.zos["listingCom"]=application.zcore.listingCom;
		}
		application.zcore.listingStruct=application.zcore.listingCom.onApplicationStart(ts);
		application.zcore.listingStruct.configCom=application.zcore.listingCom;
	}

	request.zos.requestLogEntry('Application.cfc OnApplicationListingStart end');
	</cfscript>
</cffunction>



<cffunction name="onApplicationStart" localmode="modern" access="public"  returntype="any" output="yes" hint="Fires when the application is first created.">
	<cfscript> 
	application.serverStartTickCount=gettickcount(); 
	// get all sites, and whether they have listing app, because we want to load sites not needing listing app first.
	query name="qS" datasource="#request.zos.zcoreDatasource#"{
		writeoutput("SELECT site.site_id, site_short_domain, site_domain,
		if(app_x_site_id is NULL, 0, 1) hasListingApp FROM `site` 
		LEFT JOIN app_x_site ON 
		app_x_site.site_id = site.site_id and  
		app_x_site_deleted='0' and 
		app_x_site.app_id='11' 
		WHERE site_active='1' and 
		site_deleted='0'  
		GROUP BY site.site_id");
	} 
	if(not structkeyexists(application, 'zcoreSitesLoaded')){
		application.lastSiteLoad=now();
		application.zcoreSiteDataStruct={};
		application.zcoreSitesNotLoaded={};
		application.zcoreSitesNotListingLoaded={};
		application.zcoreSitesLoaded={};
		application.zcoreSitesListingLoaded={};
		application.zcoreSitesPriorityLoadStruct={}; 
		application.zcoreSitesArrPriorityLoad=[];
		application.zcoreSitesPriorityLoadListingStruct={}; 
		application.zcoreSitesArrPriorityListingLoad=[]; 
	} 
	if(structkeyexists(application, 'siteStruct') EQ false){
		application.siteStruct=structnew();
	}
	for(row in qS){
		application.zcoreSiteDataStruct[row.site_id]=row;
		if(row.hasListingApp EQ 1){
			application.zcoreSitesNotListingLoaded[row.site_id]=true;
		}else{
			application.zcoreSitesNotLoaded[row.site_id]=true;
		}
	}
	if(not structkeyexists(application, 'zcoreSitePaths')){ 
		if(fileexists(request.zos.zcoreRootPrivatePath&"_cache/scripts/sites.json")){
			application.zcoreSitePaths=deserializeJson(fileread(request.zos.zcoreRootPrivatePath&"_cache/scripts/sites.json", "utf-8"));
		}else{
			application.zcoreSitePaths={};
		}
	}
	application.zcore.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
	</cfscript>
</cffunction>
	

<cffunction name="OnInternalApplicationStart" localmode="modern" access="public"  returntype="any" output="yes" hint="Fires when the application is first created.">
	<cfscript> 
	var ts=structnew();

	// prevent duplicate calls of this function in the same request
	if(structkeyexists(request.zos,'onApplicationStartCalled')){
		return false;
	}
	request.zos.onApplicationStartCalled=true; 


	setting requesttimeout="500";

	if(not structkeyexists(application, 'onstartcount')){
		application.onstartcount=0;
	} 
	application.onstartcount++;
	request.zos.applicationLoading=true;
       
	request.zos.requestLogEntry('Application.cfc onApplicationStart begin'); 
	if(structkeyexists(form, request.zos.urlRoutingParameter) EQ false){
		return;	
	}
	if(isDefined('request.zsession.user')){
		request.zos.userSession=duplicate(request.zsession.user);
	}else{
		request.zos.userSession=structnew();
		request.zos.userSession.groupAccess=structnew();	
	} 
	if(request.zos.zreset EQ "all"){
		setting requesttimeout="12000";
	}
	request.zos.requestLogEntry('Application.cfc onApplicationStart 1');
	
	if(request.zos.zreset EQ "app" or request.zos.zreset EQ "all" or not structkeyexists(application, 'zcore') or not structkeyexists(application.zcore, 'functions')){
		ts.zcore=structnew();
		variables.setupAppGlobals1(ts.zcore);
		request.zos.requestLogEntry('Application.cfc onApplicationStart 2');
		variables.setupAppGlobals2(ts.zcore);
		request.zos.requestLogEntry('Application.cfc onApplicationStart 3');
		application.zcore=ts.zcore;
	}
	if(request.zos.allowRequestCFC){
		request.zos.functions=application.zcore.functions;
	}
	application.zcore.functions.zClearCFMLTemplateCache(); 
	application.onstartcount=0;
	application.zcoreIsInit=true;
	application.serverStartCompletedTickCount=getTickCount();
	</cfscript>
	</cffunction>
</cfoutput>