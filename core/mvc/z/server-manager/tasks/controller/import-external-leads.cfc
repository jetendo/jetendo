<cfcomponent>
<cffunction name="index" localmode="modern" access="remote">
  <cfscript> 
  // make it work in php instead

  // make it work with email

  // make code that adapts email format to html string

  // remove the html tags, and attempt to convert remaining data into name/value pairs.

  // map the name/value pairs to common system fields, and the rest as custom fields.

  // make a feature that lets you add an import.

  // lead emails have to go to different email addresses, not all the same one.   usually plus addressing is easiest way to do that.

  /*
parse many formats.  some simple like below and others complex, like cscart/2mag


From: Squarespace <no-reply@squarespace.info>
Sent: Saturday, May 9, 2020 1:55 PM
To: one@one.com
Subject: Form Submission - New Form - System Test

 

Name: Someone

Email: one@one.com

Subject: System Test

Message: System Test

(Sent via Site)
  */

  setting requesttimeout="1000";
  if(not request.zos.isServer and not request.zos.isDeveloper){
    application.zcore.functions.z404("Only developer or server can access this");
  }
  db=request.zos.queryObject; 
  
  count=0;
  rs=application.zcore.functions.zDownloadLink("https://www.somewhere.com/export-leads.cfm?secret=something", 50, true);
  
  if(rs.success){
    arrLine=listToArray(rs.cfhttp.filecontent, chr(10), true);
    arrColumn=listToArray(arrLine[1], chr(9), true);
    ts2={};
    for(n=1;n<=arraylen(arrColumn);n++){
      ts2[arrColumn[n]]="";
    }
    for(i=2;i<=arraylen(arrLine);i++){
      line=arrLine[i];
      arrData=listToArray(line, chr(9), true);
      ts={};
      if(trim(line) EQ ""){
        continue;
      } 
      for(n=1;n<=arraylen(arrData);n++){
        ts[arrColumn[n]]=trim(arrData[n]);
      }
      structappend(ts, ts2, false);
      
      db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
      WHERE inquiries_external_id = #db.param("custom-"&ts.id)# and 
      inquiries_type_id=#db.param(3)# and 
      inquiries_type_id_siteIdType=#db.param(1)# and 
      site_id = #db.param(request.zos.globals.id)# and 
      inquiries_deleted=#db.param(0)#";
      qI=db.execute("qI");      
      
      if(qI.recordcount EQ 0){
        // insert
        
        t3={};
        t3.inquiries_external_id="custom-"&ts.id;
        t3.inquiries_type_id = 3;
        t3.inquiries_type_id_siteIdType=1;
        t3.inquiries_email=ts.email;
        t3.inquiries_first_name=ts.fName;
        t3.inquiries_last_name=ts.lname;
        t3.inquiries_state=ts.state;
        t3.inquiries_zip=ts.zipcode;
        t3.inquiries_city=ts.city;
        t3.inquiries_address=ts.address;
        t3.inquiries_address2=ts.apt;
        t3.inquiries_datetime=dateformat(ts.date, "yyyy-mm-dd")&" "&timeformat(ts.date, "HH:mm:ss");
        t3.inquiries_phone1=ts.phone;
        t3.inquiries_primary=1;
        t3.inquiries_status_id=1;
        t3.site_id=request.zos.globals.id;
        t3.inquiries_updated_datetime=request.zos.mysqlnow;
        t3.inquiries_deleted=0;
        
        //writedump(t3);
       // abort;
        a=application.zcore.functions.zImportLead(t3);
        count++;
        
      }
    }
  }
  echo('import done: #count#');
  abort;
  </cfscript>
</cffunction>
</cfcomponent>